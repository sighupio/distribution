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
  # container nodes is RAM-heavy. Use a large SHARED-vCPU instance: dedicated
  # (ccx) types are quota/capacity-limited and often can't be created.
  # cpx51 = 16 vCPU (shared AMD) / 32 GB / 360 GB — the biggest shared tier.
  # (arm64 alt: cax41, same 16/32; the vabbe node image is multi-arch.)
  default = "cpx51"
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
