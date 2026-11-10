#!/usr/bin/env bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# temp for testing
# Saves, for every control plane in furyctl.yaml: the full etcd /metrics output,
# the total count of "took too long" in the etcd log, and the node's vmstat log.
# Usage: etcd-snapshot.sh <furyctl.yaml> <label>
# Output: $DIAG_DIR/etcd-<build>/<label>/<ip>-{metrics.txt,took-too-long.txt,vmstat.log}
set -u

CONFIG="$1"
LABEL="$2"
OUT="${DIAG_DIR:-/diag}/etcd-${DRONE_BUILD_NUMBER:-local}/$LABEL"
mkdir -p "$OUT" || exit 0

SSH=(ssh -i /cache/ci-ssh-key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
  -o ConnectTimeout=5 -o LogLevel=ERROR)

# Runs on the node: try the plain metrics listener, else 2379 with the apiserver's
# etcd client certificate (paths taken from the running kube-apiserver).
# shellcheck disable=SC2016
METRICS='
for u in http://127.0.0.1:2381/metrics; do curl -fsS --max-time 10 "$u" 2>/dev/null && exit 0; done
A="$(ps -o args= -C kube-apiserver | head -1)"
ca="$(grep -oE -- "--etcd-cafile=[^ ]+" <<<"$A" | cut -d= -f2)"
crt="$(grep -oE -- "--etcd-certfile=[^ ]+" <<<"$A" | cut -d= -f2)"
key="$(grep -oE -- "--etcd-keyfile=[^ ]+" <<<"$A" | cut -d= -f2)"
curl -fsS --max-time 10 --cacert "$ca" --cert "$crt" --key "$key" https://127.0.0.1:2379/metrics
'
# shellcheck disable=SC2016
SLOW='{ journalctl -u etcd 2>/dev/null; crictl logs "$(crictl ps -q --name "^etcd$" 2>/dev/null)" 2>&1; } | grep -c "took too long"'

ips="$(sed -n '/masters:/,/nodes:/p' "$CONFIG" | grep -oE 'ip: 10\.10\.[0-9]+\.[0-9]+' | awk '{print $2}')"
for ip in $ips; do
  {
    timeout 30 "${SSH[@]}" "root@$ip" "bash -s" <<<"$METRICS" >"$OUT/$ip-metrics.txt" 2>&1
    { date -u +%FT%TZ; timeout 30 "${SSH[@]}" "root@$ip" "$SLOW" 2>&1 </dev/null; } >"$OUT/$ip-took-too-long.txt"
    timeout 30 "${SSH[@]}" "root@$ip" "cat /root/vmstat.log" >"$OUT/$ip-vmstat.log" 2>&1 </dev/null
  } &
done
wait
exit 0
