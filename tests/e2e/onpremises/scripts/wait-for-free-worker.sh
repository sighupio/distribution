#!/usr/bin/env bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Serialize on-premises and immutable e2e runs on the shared libvirt worker: block
# until no other e2e VMs (install, upgrade or immutable) are defined, then proceed.
# The worker fits roughly one full run, so runs go one at a time. State-based (no lock files to
# leak) -- it keys off the e2e VM naming. It also counts VMs that are shut off:
# the immutable pipeline defines its VMs powered off and starts them later. A
# hard-killed build whose delete step never ran leaves orphan VMs that block until
# MAX_WAIT, then this fails loudly.
set -uo pipefail

POLL="${POLL_SECONDS:-30}"
MAX_WAIT="${MAX_WAIT_SECONDS:-5400}" # 90m
VIRSH="virsh -c qemu:///system"
PAT='^(haproxy|lb|controlplane|infra|worker)-'

waited=0
while $VIRSH list --all --name 2>/dev/null | grep -qE "$PAT"; do
  if [ "$waited" -ge "$MAX_WAIT" ]; then
    echo "TIMEOUT: e2e VMs still running after ${waited}s -- possible orphans from a killed build:" >&2
    $VIRSH list --all --name 2>/dev/null | grep -E "$PAT" >&2
    exit 1
  fi
  echo "another e2e is running; waiting ${POLL}s for its VMs to go down (waited ${waited}s)"
  sleep "$POLL"
  waited=$((waited + POLL))
done
echo "worker is free of e2e VMs; proceeding."
