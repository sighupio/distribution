#!/usr/bin/env bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# On-failure cluster snapshot: dumps what's running / stuck before the VMs are
# destroyed. Writes to $DIAG_DIR (host-mounted, survives teardown) and stdout.
set -uo pipefail

SCRIPTS="$(cd "$(dirname "$0")" && pwd)"
ONPREM="$(dirname "$SCRIPTS")"
export KUBECONFIG="$ONPREM/config/kubeconfig"

OUT="${DIAG_DIR:-/diag}/snapshot-${DRONE_BUILD_NUMBER:-local}"
mkdir -p "$OUT" 2>/dev/null || OUT="/tmp/diag"
mkdir -p "$OUT"

run() { echo; echo "### $*"; timeout 60 "$@" 2>&1; }

{
  run kubectl get nodes -o wide
  run kubectl describe nodes
  run kubectl get pods -A -o wide
  echo; echo "### NOT Running/Completed"
  kubectl get pods -A 2>/dev/null | grep -vE "Running|Completed" || true
  echo; echo "### describe of not-ready pods (first 20)"
  kubectl get pods -A --no-headers 2>/dev/null | grep -vE "Running|Completed" | awk '{print $1" "$2}' | head -20 | while read -r ns p; do
    run kubectl -n "$ns" describe pod "$p"
  done
  run kubectl get pvc -A
  run kubectl get events -A --sort-by=.lastTimestamp
} | tee "$OUT/cluster.txt"

echo
echo ">>> snapshot saved to $OUT (on the worker host)"
