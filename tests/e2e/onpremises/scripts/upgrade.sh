#!/usr/bin/env bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Upgrade the cluster to the target distribution version with furyctl, using the
# rendered furyctl_upgrade.yaml. Run after install.sh (which left the pki +
# kubeconfig in config/ and a working v1.34.1 cluster). The longhorn StorageClass
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

cd "$E2E_DIR/config"

for a in 1 2 3 4 5; do
  echo ">>> furyctl upgrade (attempt ${a})"
  rm -rf /tmp/furyctl-* 2>/dev/null || true
  if furyctl apply -D --upgrade --force upgrades --config furyctl_upgrade.yaml --distro-location "$DISTRO_LOCATION"; then
    echo ">>> upgrade succeeded"
    exit 0
  fi
  echo ">>> upgrade attempt ${a} failed; retry in 60s"
  sleep 60
done
echo "furyctl upgrade failed"
exit 1
