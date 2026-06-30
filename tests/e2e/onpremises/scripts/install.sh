#!/usr/bin/env bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Install the distribution with furyctl, mirroring the original Hetzner e2e
# sequence (the known-good incantation):
#   1. kubernetes phase
#   2. full apply + distribution post-apply (retried until it succeeds) -- this is
#      what actually rolls out the storage-backed modules (loki/tempo/velero/minio/
#      prometheus); a plain single apply leaves them undeployed.
#   3. a final distribution pass once the longhorn StorageClass is available.
# (open-iscsi etc. is installed by the separate prepare-nodes step beforehand.)
set -uo pipefail

SCRIPTS="$(cd "$(dirname "$0")" && pwd)"
ONPREM="$(dirname "$SCRIPTS")"
DISTRO_LOCATION="${DISTRO_LOCATION:-/drone/src}"
export KUBECONFIG="$ONPREM/config/kubeconfig"

# tee everything to the host-mounted diag dir so the install log survives teardown
if [ -n "${DIAG_DIR:-}" ] && mkdir -p "$DIAG_DIR" 2>/dev/null; then
  exec > >(tee -a "$DIAG_DIR/install-${DRONE_BUILD_NUMBER:-local}.log") 2>&1
fi

cd "$ONPREM/config"

furyctl create pki -p ./pki || true

apply_retry() {
  # $1 = human label, rest = furyctl apply args; retried until success
  local label="$1"; shift
  local a
  for a in 1 2 3 4 5; do
    echo ">>> ${label} (attempt ${a})"
    rm -rf /tmp/furyctl-* 2>/dev/null || true
    if furyctl apply -D "$@" --distro-location "$DISTRO_LOCATION"; then
      return 0
    fi
    echo ">>> ${label} attempt ${a} failed; retry in 60s"
    sleep 60
  done
  return 1
}

# 1. full apply: kubernetes + core distribution + plugins (longhorn). furyctl SKIPS
#    the storage-backed modules (logging/tracing/dr/prometheus) here because no
#    default StorageClass exists yet -- longhorn (a plugin) creates it only now.
apply_retry "furyctl apply" --force migrations || { echo "furyctl apply failed"; exit 1; }

# 2. wait for longhorn's default StorageClass before re-applying (a blind sleep is
#    racy: longhorn-manager creates the SC a little after the plugin is installed).
echo ">>> waiting for a default StorageClass"
sc_ok=0
for i in $(seq 1 60); do
  if kubectl get storageclass 2>/dev/null | grep -qi '(default)'; then
    echo ">>> default StorageClass present"
    sc_ok=1
    break
  fi
  echo ">>> no default StorageClass yet ($i/60); waiting 10s"
  sleep 10
done
[ "$sc_ok" = 1 ] || { echo "no default StorageClass after waiting"; exit 1; }

# 3. re-apply the distribution now that the StorageClass exists -> deploys the
#    previously-skipped storage-backed modules.
apply_retry "distribution re-apply" --phase distribution || { echo "distribution re-apply failed"; exit 1; }
