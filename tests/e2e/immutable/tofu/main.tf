# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Immutable e2e infrastructure: empty-disk KVM VMs that PXE boot from the furyctl
# iPXE server. libvirt's dnsmasq gives each MAC a fixed IP and points iPXE at
# boot.ipxe, as the DHCP server of a real bare-metal site does.

terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
      # 0.9.x rewrote the schema and breaks the block syntax below.
      version = "~> 0.8.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

locals {
  # Disjoint per-run /24, outside the on-premises ranges (10..99, 110..199). The
  # install pipeline uses 200..249 (defaults), the upgrade pipeline 250..254.
  octet   = (tonumber(var.ci_number) % var.octet_span) + var.octet_base
  subnet  = "10.10.${local.octet}"
  gateway = "${local.subnet}.1"
  vip     = "${local.subnet}.20"
  ipxe    = "http://${local.gateway}:8080"
  tag     = "${var.name_prefix}-${var.ci_number}"

  # Same HA topology as on-premises, with 2 LBs for keepalived. Flatcar PXE runs
  # from RAM, so no node gets less than 3GB (the spike booted a 3GB node).
  specs = {
    lb-0           = { host = 2, cpu = 2, mem = 3072 }
    lb-1           = { host = 3, cpu = 2, mem = 3072 }
    controlplane-0 = { host = 4, cpu = 4, mem = 4096 }
    controlplane-1 = { host = 5, cpu = 4, mem = 4096 }
    controlplane-2 = { host = 6, cpu = 4, mem = 4096 }
    infra-0        = { host = 7, cpu = 4, mem = 11264 }
    infra-1        = { host = 8, cpu = 4, mem = 11264 }
    infra-2        = { host = 9, cpu = 4, mem = 11264 }
    worker-0       = { host = 10, cpu = 2, mem = 4096 }
  }

  # The hostname embeds the dashed IP so nip.io resolves it from the runner and the
  # nodes alike: Immutable uses it for SSH, etcd URLs and the API address.
  nodes = { for k, s in local.specs : k => merge(s, {
    ip   = "${local.subnet}.${s.host}"
    mac  = format("52:54:00:1e:%02x:%02x", local.octet, s.host)
    fqdn = "${k}.10-10-${local.octet}-${s.host}.nip.io"
  }) }
}

resource "libvirt_pool" "p" {
  name = local.tag
  type = "dir"
  target { path = "/var/lib/libvirt/images/${local.tag}" }
}

# The DHCP range is the whole /24, but only the reserved MACs join this network,
# so dnsmasq never leases the VIP.
resource "libvirt_network" "net" {
  name      = local.tag
  mode      = "nat"
  addresses = ["${local.subnet}.0/24"]
  autostart = true
  dhcp { enabled = true }

  dnsmasq_options {
    options {
      option_name  = "dhcp-boot"
      option_value = "${local.ipxe}/boot.ipxe"
    }
    dynamic "options" {
      for_each = local.nodes
      content {
        option_name  = "dhcp-host"
        option_value = "${options.value.mac},${options.value.ip}"
      }
    }
  }
}

# Empty disk: no ROOT label, so SeaBIOS falls through to PXE and install-flatcar
# runs. 100G virtual but thin, so longhorn has room to schedule its volumes.
resource "libvirt_volume" "disk" {
  for_each = local.nodes
  name     = "${each.key}-${local.tag}.qcow2"
  pool     = libvirt_pool.p.name
  format   = "qcow2"
  size     = 100 * 1024 * 1024 * 1024
}

# Created powered off: a VM that PXE boots before the iPXE server listens stops at
# "No bootable device". scripts/power-on.sh starts them once furyctl serves.
resource "libvirt_domain" "vm" {
  for_each = local.nodes
  name     = "${each.key}-${local.tag}"
  memory   = each.value.mem
  vcpu     = each.value.cpu
  running  = false

  cpu { mode = "host-passthrough" }

  boot_device { dev = ["hd", "network"] }

  network_interface {
    network_id = libvirt_network.net.id
    mac        = each.value.mac
  }

  disk { volume_id = libvirt_volume.disk[each.key].id }

  console {
    type        = "pty"
    target_port = "0"
  }
}
