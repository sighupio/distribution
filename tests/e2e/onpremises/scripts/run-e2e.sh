#!/usr/bin/env bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Drive the on-premises install + tests against the libvirt VMs (furyctl runs
# locally and reaches the VMs over the worker network). Run after tofu apply has
# provisioned the VMs and rendered config/{furyctl.yaml,haproxy-additional.cfg,
# req-dns.cnf} + the ingress certs.
set -uo pipefail

SCRIPTS="$(cd "$(dirname "$0")" && pwd)"
ONPREM="$(dirname "$SCRIPTS")"
TF="$ONPREM/terraform"
DISTRO_LOCATION="${DISTRO_LOCATION:-/drone/src}"
export KUBECONFIG="$ONPREM/config/kubeconfig"

cd "$ONPREM/config"

# 1. PKI + furyctl apply. Retry: early apt/PPA/GitHub blips are transient.
furyctl create pki -p ./pki || true
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

# 2. distribution component checks
bats -t "$ONPREM/tests/e2e-onpremises.sh"

# 3. CIS kube-bench (ansible) on ONE representative node per role — controlplane-0
# + worker-0 — exactly as the original e2e. The play clones the SIGHUP kube-bench
# config from installer-on-premises and fails on any failed check.
cp -f "$ONPREM/config/kubeconfig" /cache/kubeconfig
CP0="$(cd "$TF" && tofu output -raw controlplane_0_ip)"
WK0="$(cd "$TF" && tofu output -raw worker_0_ip)"
INV="$ONPREM/config/kube-bench-hosts.yaml"
cat > "$INV" <<EOF
all:
  children:
    controlplane_nodes:
      hosts:
        controlplane-0:
          ansible_host: "${CP0}"
    worker_nodes:
      hosts:
        worker-0:
          ansible_host: "${WK0}"
  vars:
    ansible_python_interpreter: python3
    ansible_ssh_private_key_file: "/cache/ci-ssh-key"
    ansible_user: "root"
EOF
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i "$INV" "$ONPREM/playbooks/kube-bench.yaml"
