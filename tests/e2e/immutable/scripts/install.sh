#!/usr/bin/env bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# The on-premises install sequence (pki, apply with retries, wait for the longhorn
# StorageClass, distribution re-apply), with power-on.sh in the background to boot
# the VMs while the first apply serves the iPXE assets. A retried apply finds the
# nodes up and skips the boot wait.
set -uo pipefail

SCRIPTS="$(cd "$(dirname "$0")" && pwd)"
E2E_DIR="$(dirname "$SCRIPTS")"
export E2E_DIR

bash "$SCRIPTS/power-on.sh" &
power=$!

bash "$E2E_DIR/../onpremises/scripts/install.sh"
rc=$?

# Still waiting for the server only if the install failed before it served.
kill "$power" 2>/dev/null || true
exit "$rc"
