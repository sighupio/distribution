# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# On-premises e2e infrastructure: real KVM VMs on the Drone worker via libvirt.
# Faithful to a bare-metal on-prem cluster (full kernel) so cilium/calico,
# longhorn and kube-bench behave as in production. Shared by the install and the
# upgrade pipelines, parameterised so their resources never collide.

terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      # pin 0.8.x: 0.9.x rewrote the schema to typed attributes and breaks the
      # block syntax (network_interface/disk/console) used below.
      version = "~> 0.8.0"
    }
  }
}

locals {
  # Disjoint per-run /24 so concurrent runs (and the two pipelines) never collide.
  octet  = (tonumber(var.ci_number) % var.octet_span) + var.octet_base
  subnet = "10.10.${local.octet}"

  # HA topology: haproxy + 3 control planes + 3 infra + 1 worker.
  # Sizes tuned for the worker (62GB/16 threads); control planes need >=2 vCPU
  # for the kubeadm preflight.
  nodes = {
    haproxy        = { ip = "${local.subnet}.2", cpu = 1, mem = 1024 }
    controlplane-0 = { ip = "${local.subnet}.3", cpu = 4, mem = 4096 }
    controlplane-1 = { ip = "${local.subnet}.4", cpu = 4, mem = 4096 }
    controlplane-2 = { ip = "${local.subnet}.5", cpu = 4, mem = 4096 }
    infra-0        = { ip = "${local.subnet}.6", cpu = 4, mem = 12288 }
    infra-1        = { ip = "${local.subnet}.7", cpu = 4, mem = 12288 }
    infra-2        = { ip = "${local.subnet}.8", cpu = 4, mem = 12288 }
    worker-0       = { ip = "${local.subnet}.9", cpu = 2, mem = 4096 }
  }

  # name_prefix-ci_number is unique per pipeline+run: domains are global in
  # libvirt, so the prefix is what keeps install (e2e-*) and upgrade (e2eup-*)
  # VMs from clashing. The role-prefixed name still matches the gate/cleanup regex.
  tag = "${var.name_prefix}-${var.ci_number}"
}

resource "libvirt_pool" "p" {
  name = local.tag
  type = "dir"
  target { path = "/var/lib/libvirt/images/${local.tag}" }
}

resource "libvirt_network" "net" {
  name      = local.tag
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
  name     = "${each.key}-${local.tag}.qcow2"
  pool     = libvirt_pool.p.name
  source   = var.base_image
  format   = "qcow2"
}

resource "libvirt_cloudinit_disk" "ci" {
  for_each       = local.nodes
  name           = "ci-${each.key}-${local.tag}.iso"
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
  name      = "${each.key}-${local.tag}"
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
