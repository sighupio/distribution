#!/usr/bin/env bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Upgrade the cluster to the target distribution version with furyctl, using the
# rendered furyctl_upgrade.yaml. Run after install.sh (which left the pki +
# kubeconfig in config/ and a working cluster at the base version). The longhorn StorageClass
# already exists from the base install, so a single apply rolls out everything.
set -uo pipefail

SCRIPTS="$(cd "$(dirname "$0")" && pwd)"
ONPREM="$(dirname "$SCRIPTS")"
E2E_DIR="${E2E_DIR:-$ONPREM}"
DISTRO_LOCATION="${DISTRO_LOCATION:-/drone/src}"
export KUBECONFIG="$E2E_DIR/config/kubeconfig"

if [ -n "${DIAG_DIR:-}" ] && mkdir -p "$DIAG_DIR" 2>/dev/null; then
  exec > >(tee -a "$DIAG_DIR/upgrade-${DRONE_BUILD_NUMBER:-local}.log") 2>&1
fi

cd "$E2E_DIR/config" || exit 1

# Single attempt: an upgrade failure (e.g. a node drain blocked by a PDB) is
# deterministic, not a transient blip -- retrying only burns the pipeline's clock.
# If it fails, it fails; the log shows where.
# POD_RUNNING_CHECK_TIMEOUT (seconds), set by the Immutable upgrade pipeline: its pod-settle
# wait after each node's reboot is 15s per retry, so furyctl's 300s default is only 150s.
timeout_flag=()
[ -n "${POD_RUNNING_CHECK_TIMEOUT:-}" ] && timeout_flag=(--pod-running-check-timeout "$POD_RUNNING_CHECK_TIMEOUT")

echo ">>> furyctl upgrade"
rm -rf /tmp/furyctl-* 2>/dev/null || true
furyctl apply -D --upgrade --force upgrades --config furyctl_upgrade.yaml --distro-location "$DISTRO_LOCATION" "${timeout_flag[@]}"
rc=$?

# On failure, show which pods are not Ready (the pod-settle wait only prints a count).
if [ "$rc" -ne 0 ]; then
  echo ">>> pods not Ready after the failed upgrade"
  kubectl get pods -A -o wide | awk 'NR == 1 || $4 != "Completed" && !($4 == "Running" && split($3, r, "/") == 2 && r[1] == r[2])' || true
  kubectl get events -A --sort-by=.lastTimestamp | tail -50 || true
fi
exit "$rc"
