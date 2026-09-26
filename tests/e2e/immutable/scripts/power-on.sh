#!/usr/bin/env bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# The operator's part of an Immutable install: power on the VMs once the furyctl
# iPXE server answers, then watch the boot. furyctl waits for every node to report
# "booted" with no timeout, so on BOOT_TIMEOUT this stops the install instead of
# letting the step hang, and saves each VM's screen to DIAG_DIR.
set -uo pipefail

IMM="$(cd "$(dirname "$0")/.." && pwd)"
TF="$IMM/tofu"
VIRSH="virsh -c qemu:///system"
URL="$(cd "$TF" && tofu output -raw ipxe_url)"
VMS="$(cd "$TF" && tofu output -json vms | jq -r '.[]')"
SERVE_TIMEOUT="${SERVE_TIMEOUT:-1800}" # asset download before the server starts
BOOT_TIMEOUT="${BOOT_TIMEOUT:-1800}"

status() { curl -fsS -m 5 "$URL/status" 2>/dev/null; }

abort() {
  echo "POWER-ON: $1" >&2
  status >&2 || true
  if [ -n "${DIAG_DIR:-}" ] && mkdir -p "$DIAG_DIR" 2>/dev/null; then
    for vm in $VMS; do $VIRSH screenshot "$vm" "$DIAG_DIR/${vm}-${DRONE_BUILD_NUMBER:-local}.ppm" >/dev/null 2>&1; done
  fi
  pkill -f onpremises/scripts/install.sh
  pkill -f "furyctl apply"
  exit 1
}

waited=0
until status >/dev/null; do
  [ "$waited" -ge "$SERVE_TIMEOUT" ] && abort "iPXE server at $URL did not start in ${waited}s"
  sleep 10
  waited=$((waited + 10))
done

for vm in $VMS; do $VIRSH start "$vm"; done

# The server stops once every node reports "booted", so an unreachable server
# after this point means the boot is done.
waited=0
while s="$(status)"; do
  [ "$waited" -ge "$BOOT_TIMEOUT" ] && abort "nodes did not boot in ${waited}s"
  echo "POWER-ON: $s"
  sleep 30
  waited=$((waited + 30))
done
echo "POWER-ON: every node booted"
