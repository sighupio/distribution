#!/usr/bin/env bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Run the node-prerequisites playbook (open-iscsi etc.) on every VM, before furyctl.
# Inventory is built from tofu output.
set -uo pipefail

SCRIPTS="$(cd "$(dirname "$0")" && pwd)"
ONPREM="$(dirname "$SCRIPTS")"
# E2E_DIR lets the upgrades pipeline reuse this against its own tofu/config.
E2E_DIR="${E2E_DIR:-$ONPREM}"
TF="$E2E_DIR/tofu"

INV="$E2E_DIR/config/prepare-hosts.ini"
{
  echo "[nodes]"
  for ip in $(cd "$TF" && tofu output -raw all_ips); do echo "$ip"; done
  echo
  echo "[nodes:vars]"
  echo "ansible_user=root"
  echo "ansible_ssh_private_key_file=/cache/ci-ssh-key"
  echo "ansible_ssh_common_args=-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
} > "$INV"

ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i "$INV" "$ONPREM/playbooks/prepare-nodes.yaml"
