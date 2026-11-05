#!/usr/bin/env bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Samples host, node and cluster load during the install. Node samples go over
# ssh so they keep working while the API server is starved. The log lives in the
# host-mounted diag dir, so it survives the teardown and a killed build.
set -u

CONFIG="$1"
OUT="$2"
INTERVAL="${SAMPLER_INTERVAL:-60}"

SSH=(ssh -i /cache/ci-ssh-key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
  -o ConnectTimeout=5 -o LogLevel=ERROR)
# shellcheck disable=SC2016
REMOTE='top -bn1 -o %CPU -w 110 | sed -n "3p;8,13p"
echo "etcd slow/min: $( { journalctl -u etcd --since "-1 min" 2>/dev/null; crictl logs --since 1m "$(crictl ps -q --name "^etcd$" 2>/dev/null)" 2>&1; } | grep -c "took too long")"'
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"; exit 0' EXIT TERM INT

prev_total=0
prev_idle=0

while :; do
  {
    echo "=== $(date -u +%FT%TZ) load: $(cut -d' ' -f1-3 /proc/loadavg)"

    # /proc/stat is not namespaced: these are the worker's own counters.
    read -r _ user nice system idle iowait irq softirq steal _ </proc/stat
    total=$((user + nice + system + idle + iowait + irq + softirq + steal))
    if [ "$prev_total" -gt 0 ] && [ "$total" -gt "$prev_total" ]; then
      echo "host idle%: $(((idle - prev_idle) * 100 / (total - prev_total)))"
    fi
    prev_total="$total"
    prev_idle="$idle"

    i=0
    while read -r ip; do
      i=$((i + 1))
      { echo "--- $ip"; timeout 25 "${SSH[@]}" "root@$ip" "$REMOTE" 2>&1 </dev/null; } >"$TMP/$i" &
    done < <(grep -oE 'ip: 10\.10\.[0-9]+\.[0-9]+' "$CONFIG" | awk '{print $2}')
    wait
    cat "$TMP"/* 2>/dev/null
    rm -f "$TMP"/*

    echo "--- pods by status"
    timeout 20 kubectl get pods -A --no-headers 2>&1 | awk '{print $4}' | sort | uniq -c
    echo "--- top pods"
    timeout 20 kubectl top pods -A --sort-by=cpu 2>&1 | head -16
  } >>"$OUT" 2>&1
  sleep "$INTERVAL"
done
