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
# E2E_DIR/BATS_SUITE let the upgrades pipeline reuse this for its own tests dir and
# run a specific suite (post-install vs post-upgrade). Defaults to this pipeline.
E2E_DIR="${E2E_DIR:-$ONPREM}"
BATS_SUITE="${BATS_SUITE:-e2e-onpremises.sh}"
export KUBECONFIG="$E2E_DIR/config/kubeconfig"

TIMEOUT="${BATS_TIMEOUT:-3600}" # 60m
LOG="${DIAG_DIR:+${DIAG_DIR}/bats-${DRONE_BUILD_NUMBER:-local}.log}"
LOG="${LOG:-/tmp/bats.log}"
mkdir -p "$(dirname "$LOG")" 2>/dev/null || true

timeout "$TIMEOUT" bats -t "$E2E_DIR/tests/$BATS_SUITE" 2>&1 | tee "$LOG"
exit "${PIPESTATUS[0]}"
