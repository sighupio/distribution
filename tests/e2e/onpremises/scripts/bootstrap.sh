#!/usr/bin/env bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Single-VM on-premises install e2e via vabbe.
#
# Least-intrusive test path: run this on ONE Linux box with Docker (a throwaway
# Hetzner VM, or locally on Docker Desktop). It needs NO tofu multi-VM dance, NO
# installer patches, NO drone changes — just `mise + vabbe` on a Docker host.
#
# Requires in the environment:
#   - docker, mise, and the vabbe CLI (mise installs vabbe via this folder's mise.toml)
#   - GITHUB_TOKEN exported (furyctl/mise hit the GitHub API; without it you get 403s)
#
# Usage:  GITHUB_TOKEN=$(gh auth token) ./scripts/bootstrap.sh
set -euo pipefail

# Layout: this script lives in scripts/; the cluster payload (vabbe.yaml,
# furyctl.yaml, mise.toml, certs) lives in ../config. We operate from config/ so
# all of vabbe's and furyctl's relative paths (mounts, {file://./...}, tls.*,
# pki, kubeconfig) resolve there.
SCRIPTS="$(cd "$(dirname "$0")" && pwd)"
ONPREM="$(dirname "$SCRIPTS")"
cd "$ONPREM/config"

: "${GITHUB_TOKEN:?export GITHUB_TOKEN (e.g. GITHUB_TOKEN=\$(gh auth token)) — furyctl/mise need it}"

echo "### 0. tools (vabbe + runner toolchain pinned in mise.toml)"
mise trust >/dev/null 2>&1 || true
mise install

VABBE="mise exec -- vabbe"

echo "### 1. lab SSH key (must exist before 'up' — runner mounts it)"
$VABBE keygen

echo "### 2. host-prep: swap off + kernel modules on THIS host/VM"
# On a real Linux VM this runs as root directly (swapoff/modprobe); on Docker
# Desktop it enters the VM via nsenter. --run actually applies it.
$VABBE host-prep --run

echo "### 3. bring up the lab (1 haproxy + 3 cp + 3 worker + runner)"
$VABBE up --wait

echo "### 4. ingress certificates (written into config/ for furyctl)"
bash "$SCRIPTS/create_ingress_certs.sh"

echo "### 5. drive furyctl from inside the in-network 'runner' node"
# We always drive from the runner. It works EVERYWHERE (container→container is
# routable on both macOS and Linux), so one path covers both hosts.
#
# NOTE (Linux VM optimization, not used here): on a real Hetzner VM the Docker
# bridge is also routable FROM the host, so you could run furyctl natively on the
# VM (no runner) using `vabbe inventory` for the ansible hosts and copying the lab
# key to the VM's ssh path. The runner path below avoids that host-specific wiring
# and is what we validate on macOS — keep it unless you have a reason not to.
#
# kubernetes phase is retried — early apt/PPA/GitHub blips are transient.
docker exec -e GITHUB_TOKEN="$GITHUB_TOKEN" onprem135.runner bash -lc '
  set -uo pipefail
  export PATH=/mise/shims:/usr/local/bin:/usr/bin:/bin MISE_TRUSTED_CONFIG_PATHS=/distribution MISE_YES=1
  cd /work
  mise trust >/dev/null 2>&1 || true
  mise install
  furyctl create pki -p ./pki || true
  for a in 1 2 3; do
    echo ">>> furyctl apply attempt $a"
    rm -f /tmp/furyctl-* 2>/dev/null || true
    furyctl apply -D --force migrations --distro-location /distribution && break
    echo ">>> attempt $a failed; retrying after 15s"; sleep 15
  done
'

echo "### 6. cluster state"
docker exec onprem135.runner bash -lc 'export PATH=/mise/shims:$PATH; kubectl --kubeconfig /work/kubeconfig get nodes -o wide; echo; kubectl --kubeconfig /work/kubeconfig get pods -A | grep -vE "Running|Completed" || echo "all pods Running/Completed"'

echo
echo "### done. Tear down with:  mise exec -- vabbe down"
