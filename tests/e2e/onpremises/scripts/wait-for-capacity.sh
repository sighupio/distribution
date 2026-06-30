#!/usr/bin/env bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Admission gate for concurrent on-prem e2e runs sharing one libvirt worker.
# This run needs ~35GB; the worker has ~62GB, so two full runs would OOM. Block
# (poll) until the RAM already committed by running libvirt domains leaves enough
# headroom for ours — i.e. the run effectively stays "pending" instead of failing.
#
# Tunables (env): REQUIRED_MB (this run's footprint), RESERVE_MB (host/system
# reserve kept free), POLL_SECONDS, MAX_WAIT_SECONDS.
set -uo pipefail

REQUIRED_MB="${REQUIRED_MB:-36000}"   # ~35GB of VMs + a little slack
RESERVE_MB="${RESERVE_MB:-8192}"      # leave this much for the host itself
POLL_SECONDS="${POLL_SECONDS:-30}"
MAX_WAIT_SECONDS="${MAX_WAIT_SECONDS:-5400}"  # 90m: give a busy worker time to drain
VIRSH="virsh -c qemu:///system"

total_mb=$(awk '/MemTotal/{print int($2/1024)}' /proc/meminfo)
usable_mb=$(( total_mb - RESERVE_MB ))

committed_mb() {
  # sum of Max memory (KiB) over running domains = worst-case RAM they can use
  local sum=0 m
  for d in $($VIRSH list --name --state-running 2>/dev/null | grep .); do
    m=$($VIRSH dominfo "$d" 2>/dev/null | awk '/Max memory/{print $3}')
    sum=$(( sum + ${m:-0} ))
  done
  echo $(( sum / 1024 ))
}

waited=0
while :; do
  used=$(committed_mb)
  n=$($VIRSH list --name --state-running 2>/dev/null | grep -c . || echo 0)
  if [ $(( used + REQUIRED_MB )) -le "$usable_mb" ]; then
    echo "capacity OK: ${n} libvirt VM(s) committing ${used}MB; need ${REQUIRED_MB}MB; usable ${usable_mb}MB. proceeding."
    exit 0
  fi
  if [ "$waited" -ge "$MAX_WAIT_SECONDS" ]; then
    echo "capacity gate TIMEOUT after ${waited}s: ${used}MB committed by ${n} VM(s), need ${REQUIRED_MB}MB free of ${usable_mb}MB usable." >&2
    exit 1
  fi
  echo "waiting for capacity: ${n} libvirt VM(s) committing ${used}MB, need ${REQUIRED_MB}MB free of ${usable_mb}MB usable; retry in ${POLL_SECONDS}s (waited ${waited}s)"
  sleep "$POLL_SECONDS"
  waited=$(( waited + POLL_SECONDS ))
done
