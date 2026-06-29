#!/usr/bin/env bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Run the CIS kube-bench benchmark on every control-plane and worker node.
# The nodes are vabbe containers (not VMs), so we `docker exec` into each one and
# run kube-bench there — it inspects the node's real kubeadm config files, exactly
# as it would on a bare-metal node. Fails (exit 1) if any check fails.
set -euo pipefail

KB_VERSION="${KB_VERSION:-0.12.0}"
LAB="${LAB:-onprem135}"

nodes=$(docker ps --format '{{.Names}}' | grep -E "^${LAB}\.(controlplane|worker)" || true)
[ -n "$nodes" ] || { echo "no ${LAB} control-plane/worker node containers found"; exit 1; }

rc=0
for n in $nodes; do
  echo "==================== kube-bench: $n ===================="
  docker exec "$n" bash -c '
    set -e
    arch=$(dpkg --print-architecture)
    if [ ! -x /opt/kube-bench/kube-bench ]; then
      mkdir -p /opt/kube-bench
      curl -fsSL "https://github.com/aquasecurity/kube-bench/releases/download/v'"$KB_VERSION"'/kube-bench_'"$KB_VERSION"'_linux_${arch}.tar.gz" \
        | tar xz -C /opt/kube-bench
    fi
    cd /opt/kube-bench
    ./kube-bench run --config-dir ./cfg --config ./cfg/config.yaml --exit-code 1
  ' || rc=1
done

exit $rc
