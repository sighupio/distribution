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
  # container nodes is RAM-heavy → use a large SHARED-vCPU instance (dedicated
  # ccx types are quota-limited). cpx62 = shared AMD, the largest available
  # shared tier — plenty of RAM headroom for the full stack.
  default = "cpx62"
}

variable "location" {
  type = string
  # fsn1 (Falkenstein) is Hetzner's largest DC → best chance of capacity.
  # Alternatives: nbg1 (Nuremberg), hel1 (Helsinki).
  default = "fsn1"
}

resource "hcloud_server" "vm" {
  name         = "e2e-onpremises-${var.ci_number}"
  image        = "ubuntu-24.04"
  server_type  = var.server_type
  location     = var.location
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
