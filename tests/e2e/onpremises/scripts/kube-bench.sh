#!/usr/bin/env bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Run the CIS kube-bench benchmark (ansible) on one representative node per role
# -- controlplane-0 + worker-0 -- as the original e2e. Builds the inventory from
# tofu output and runs playbooks/kube-bench.yaml (SIGHUP installer-on-premises config).
set -uo pipefail

SCRIPTS="$(cd "$(dirname "$0")" && pwd)"
ONPREM="$(dirname "$SCRIPTS")"
# E2E_DIR lets the upgrades pipeline reuse this against its own tofu/config.
E2E_DIR="${E2E_DIR:-$ONPREM}"
TF="$E2E_DIR/tofu"

# the playbook copies /cache/kubeconfig onto the nodes
cp -f "$E2E_DIR/config/kubeconfig" /cache/kubeconfig

CP0="$(cd "$TF" && tofu output -raw controlplane_0_ip)"
WK0="$(cd "$TF" && tofu output -raw worker_0_ip)"

INV="$E2E_DIR/config/kube-bench-hosts.yaml"
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
