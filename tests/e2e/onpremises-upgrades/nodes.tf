# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.
resource "hcloud_server" "haproxy" {
  name        = "haproxy-0-upgrades-${var.ci_number}"
  image       = "ubuntu-24.04"
  server_type = "cpx31"
  location    = "nbg1"

  ssh_keys = [hcloud_ssh_key.ssh_key.id]
  network {
    network_id = hcloud_network.network.id
    ip         = "10.10.1.2"
  }
  firewall_ids = [hcloud_firewall.haproxy.id]
}

resource "null_resource" "init_haproxy" {
  triggers = {
    instance_id   = hcloud_server.haproxy.id
    private_key   = var.private_key
  }

  connection {
    type        = "ssh"
    host        = hcloud_server.haproxy.ipv4_address
    user        = "root"
    private_key = var.private_key
  }

  provisioner "remote-exec" {
    inline = [ 
      "echo \"IdentityFile ~/.ssh/id_ed25519\" > /root/.ssh/config ",
      "echo \"${var.private_key}\" > /root/.ssh/id_ed25519",
      "chmod 600 /root/.ssh/id_ed25519"
     ]
  }

}

resource "hcloud_server" "controlplane" {
  count       = 3
  name        = "controlplane-upgrades-${count.index}-${var.ci_number}"
  image       = "ubuntu-24.04"
  server_type = "cpx31"
  location    = "nbg1"
  ssh_keys    = [hcloud_ssh_key.ssh_key.id]
  network {
    network_id = hcloud_network.network.id
    ip         = "10.10.1.${count.index + 3}"
  }
  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }
}

resource "hcloud_server" "infra" {
  count       = 3
  name        = "infra-upgrades-${count.index}-${var.ci_number}"
  image       = "ubuntu-24.04"
  server_type = "cpx41"
  location    = "nbg1"
  ssh_keys    = [hcloud_ssh_key.ssh_key.id]
  network {
    network_id = hcloud_network.network.id
    ip         = "10.10.1.${count.index + 6}"
  }
    public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }
}

resource "hcloud_server" "worker" {
  count       = 2
  name        = "worker-upgrades-${count.index}-${var.ci_number}"
  image       = "ubuntu-24.04"
  server_type = "cpx41"
  location    = "nbg1"
  ssh_keys    = [hcloud_ssh_key.ssh_key.id]
  network {
    network_id = hcloud_network.network.id
    ip         = "10.10.1.${count.index + 9}"
  }
  public_net {
    ipv4_enabled = true
    ipv6_enabled = false
  }
}
