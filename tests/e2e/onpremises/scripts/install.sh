#!/usr/bin/env bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Install the distribution with furyctl: create the pki, then one full apply,
# retried until it succeeds. When the longhorn StorageClass appears, furyctl
# applies the distribution phase again for the storage-backed modules.
# (open-iscsi etc. is installed by the separate prepare-nodes step beforehand.)
set -uo pipefail

SCRIPTS="$(cd "$(dirname "$0")" && pwd)"
ONPREM="$(dirname "$SCRIPTS")"
# E2E_DIR lets a sibling pipeline (e.g. onpremises-upgrades) reuse this script
# against its own tofu/config dirs; defaults to this script's own pipeline.
E2E_DIR="${E2E_DIR:-$ONPREM}"
DISTRO_LOCATION="${DISTRO_LOCATION:-/drone/src}"
export KUBECONFIG="$E2E_DIR/config/kubeconfig"

# tee everything to the host-mounted diag dir so the install log survives teardown
if [ -n "${DIAG_DIR:-}" ] && mkdir -p "$DIAG_DIR" 2>/dev/null; then
  exec > >(tee -a "$DIAG_DIR/install-${DRONE_BUILD_NUMBER:-local}.log") 2>&1
fi

cd "$E2E_DIR/config" || exit 1

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

apply_retry "furyctl apply" --force migrations || { echo "furyctl apply failed"; exit 1; }
