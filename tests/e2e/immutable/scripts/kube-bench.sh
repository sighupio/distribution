#!/usr/bin/env bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Run the on-premises CIS kube-bench playbook on controlplane-0 and worker-0.
# Flatcar has no package manager and SSH is as core, so the inventory skips the
# package install and becomes root.
set -euo pipefail

IMM="$(cd "$(dirname "$0")/.." && pwd)"
TF="$IMM/tofu"

# the playbook copies /cache/kubeconfig onto the nodes
cp -f "$IMM/config/kubeconfig" /cache/kubeconfig

CP0="$(cd "$TF" && tofu output -raw controlplane_0)"
WK0="$(cd "$TF" && tofu output -raw worker_0)"
# ansible-playbook exits 0 when no host matches, so an empty name would pass with no check.
if [ -z "$CP0" ] || [ -z "$WK0" ]; then
  echo "kube-bench: tofu output has no controlplane_0 or worker_0" >&2
  exit 1
fi

INV="$IMM/config/kube-bench-hosts.yaml"
cat > "$INV" <<EOF
all:
  children:
    controlplane_nodes:
      hosts:
        ${CP0}:
    worker_nodes:
      hosts:
        ${WK0}:
  vars:
    ansible_python_interpreter: python3
    ansible_ssh_private_key_file: "/cache/ci-ssh-key"
    ansible_user: core
    ansible_become: true
    kube_bench_install_packages: false
EOF

ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i "$INV" "$IMM/../onpremises/playbooks/kube-bench.yaml"
