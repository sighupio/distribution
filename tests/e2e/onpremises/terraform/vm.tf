# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Single throwaway VM that hosts the whole on-premises cluster: the Kubernetes
# nodes are Docker containers acting like VMs (brought up by vabbe) INSIDE this
# box. One VM instead of nine — no private network, no per-node provisioning.
# It just needs Docker; vabbe + furyctl do the rest in `bootstrap.sh`.

variable "server_type" {
  type = string
  # The full distribution (cilium, opensearch, mimir, velero, ...) across 7
  # container nodes is RAM-heavy → use a large SHARED-vCPU instance. Dedicated
  # (ccx) types are quota-limited, and the older shared AMD line (cpx*) is EOL /
  # no longer orderable in hel1. The current shared line that's available is CAX
  # (Ampere ARM): cax41 = 16 vCPU / 32 GB / 320 GB. arm64 is also exactly what we
  # validated locally, and the vabbe node + KFD images are multi-arch.
  default = "cax41"
}

resource "hcloud_server" "vm" {
  name         = "e2e-onpremises-${var.ci_number}"
  image        = "ubuntu-24.04"
  server_type  = var.server_type
  location     = "hel1"
  ssh_keys     = [hcloud_ssh_key.ssh_key.id]
  firewall_ids = [hcloud_firewall.vm.id]
  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }
  # cloud-init: install Docker + git so the box is a ready Docker host.
  user_data = <<-EOF
    #cloud-config
    package_update: true
    packages:
      - git
      - curl
    runcmd:
      - curl -fsSL https://get.docker.com | sh
      - systemctl enable --now docker
  EOF
}
