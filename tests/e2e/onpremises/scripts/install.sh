#!/usr/bin/env bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Install the distribution with furyctl. Runs the apply TWICE: the storage-backed
# stateful components (minio/velero/loki/tempo) only schedule once the longhorn
# StorageClass exists, which is created during the first apply. The second
# distribution-phase apply lets them land -- mirrors the original Hetzner e2e.
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

# first full apply; retry transient apt/PPA/GitHub blips
ok=0
for a in 1 2 3; do
  echo ">>> furyctl apply attempt $a"
  rm -rf /tmp/furyctl-* 2>/dev/null || true
  if furyctl apply -D --force migrations --distro-location "$DISTRO_LOCATION"; then
    ok=1
    break
  fi
  echo ">>> attempt $a failed; retry in 15s"
  sleep 15
done
[ "$ok" = 1 ] || { echo "furyctl apply failed after retries"; exit 1; }

# NOTE: no second distribution apply. open-iscsi (prepare-nodes) makes longhorn
# attach volumes on the first pass, so a single apply brings the whole cluster up.
# Re-applying afterwards only re-rolls a healthy cluster and overloads the
# apiserver -- it was a workaround for the storage race that open-iscsi root-fixed.
