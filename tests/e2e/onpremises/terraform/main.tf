# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# On-premises e2e infrastructure: real KVM VMs on the Drone worker via libvirt
# (replaces the old Hetzner provider). Faithful to a bare-metal on-prem cluster —
# full kernel, so cilium/longhorn/kube-bench behave as in production.

terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      # pin 0.8.x: 0.9.x rewrote the schema to typed attributes and breaks the
      # block syntax (network_interface/disk/console) used below.
      version = "~> 0.8.0"
    }
  }
  # Local state: the run is ephemeral and the apply/destroy steps share the Drone
  # workspace, so no remote backend is needed.
}

provider "libvirt" {
  uri = "qemu:///system"
}

locals {
  # Derive a per-run /24 from the build number so concurrent CI runs get isolated
  # networks/subnets on the shared worker and never collide.
  octet  = (tonumber(var.ci_number) % 200) + 10
  subnet = "10.10.${local.octet}"

  # Hetzner HA topology: haproxy + 3 control planes + 3 infra + 2 workers.
  # Sizes tuned for the worker (62GB/16 threads); control planes need >=2 vCPU
  # for the kubeadm preflight.
  nodes = {
    haproxy        = { ip = "${local.subnet}.2", cpu = 1, mem = 1024 }
    controlplane-0 = { ip = "${local.subnet}.3", cpu = 2, mem = 2560 }
    controlplane-1 = { ip = "${local.subnet}.4", cpu = 2, mem = 2560 }
    controlplane-2 = { ip = "${local.subnet}.5", cpu = 2, mem = 2560 }
    infra-0        = { ip = "${local.subnet}.6", cpu = 2, mem = 6144 }
    infra-1        = { ip = "${local.subnet}.7", cpu = 2, mem = 6144 }
    infra-2        = { ip = "${local.subnet}.8", cpu = 2, mem = 6144 }
    worker-0       = { ip = "${local.subnet}.9", cpu = 2, mem = 4096 }
    worker-1       = { ip = "${local.subnet}.10", cpu = 2, mem = 4096 }
  }
}

resource "libvirt_pool" "p" {
  name = "e2e-${var.ci_number}"
  type = "dir"
  target { path = "/var/lib/libvirt/images/e2e-${var.ci_number}" }
}

resource "libvirt_network" "net" {
  name      = "e2e-${var.ci_number}"
  mode      = "nat"
  addresses = ["${local.subnet}.0/24"]
  autostart = true
  dhcp { enabled = false } # static IPs via cloud-init
}

# Full per-node copy (no CoW backing chain): virt-aa-helper on the worker does not
# emit per-VM disk allow-lists, and a backing file would need an extra AppArmor
# rule it omits. A standalone disk needs only the one allow the libvirt role adds.
resource "libvirt_volume" "disk" {
  for_each = local.nodes
  name     = "${each.key}-${var.ci_number}.qcow2"
  pool     = libvirt_pool.p.name
  source   = var.base_image
  format   = "qcow2"
}

resource "libvirt_cloudinit_disk" "ci" {
  for_each       = local.nodes
  name           = "ci-${each.key}-${var.ci_number}.iso"
  pool           = libvirt_pool.p.name
  user_data      = <<-EOT
    #cloud-config
    hostname: ${each.key}
    disable_root: false
    ssh_pwauth: false
    users:
      - name: root
        ssh_authorized_keys:
          - ${trimspace(var.public_key)}
    runcmd:
      - [ systemctl, enable, --now, ssh ]
  EOT
  network_config = <<-EOT
    version: 2
    ethernets:
      primary:
        match: { name: "e*" }
        addresses: [${each.value.ip}/24]
        gateway4: ${local.subnet}.1
        nameservers:
          addresses: [8.8.8.8, 1.1.1.1]
  EOT
}

resource "libvirt_domain" "vm" {
  for_each  = local.nodes
  name      = "${each.key}-${var.ci_number}"
  memory    = each.value.mem
  vcpu      = each.value.cpu
  cloudinit = libvirt_cloudinit_disk.ci[each.key].id

  cpu { mode = "host-passthrough" }

  network_interface {
    network_id = libvirt_network.net.id
    addresses  = [each.value.ip]
  }

  disk { volume_id = libvirt_volume.disk[each.key].id }

  console {
    type        = "pty"
    target_port = "0"
  }
}
