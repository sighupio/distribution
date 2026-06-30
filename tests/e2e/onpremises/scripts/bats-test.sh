#!/usr/bin/env bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Run the bats distribution checks, tee'd to the diag dir (survives teardown) so a
# timeout/failure shows which check was stuck. Bounded so a hang fails the step
# (then delete destroys) instead of running forever.
set -uo pipefail

SCRIPTS="$(cd "$(dirname "$0")" && pwd)"
ONPREM="$(dirname "$SCRIPTS")"
export KUBECONFIG="$ONPREM/config/kubeconfig"

TIMEOUT="${BATS_TIMEOUT:-3600}" # 60m
LOG="${DIAG_DIR:+${DIAG_DIR}/bats-${DRONE_BUILD_NUMBER:-local}.log}"
LOG="${LOG:-/tmp/bats.log}"
mkdir -p "$(dirname "$LOG")" 2>/dev/null || true

# install just succeeded -> everything is up; snapshot the real pod labels so we
# can verify the bats queries actually match what's deployed (a mismatched
# label/namespace makes a check hang for its whole loop_it budget).
if [ -n "${DIAG_DIR:-}" ]; then
  kubectl get pods -A --show-labels > "${DIAG_DIR}/pod-labels-${DRONE_BUILD_NUMBER:-local}.txt" 2>&1 || true
fi

timeout "$TIMEOUT" bats -t "$ONPREM/tests/e2e-onpremises.sh" 2>&1 | tee "$LOG"
exit "${PIPESTATUS[0]}"
