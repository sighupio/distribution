# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Install pipeline infrastructure. The VMs come from the shared module; this root
# only renders the furyctl.yaml (see output.tf). name_prefix "e2e" + the 10..99
# subnet range keep it disjoint from the upgrade pipeline (e2eup / 110..199).
terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.8.0"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

module "vms" {
  source      = "./modules/vms"
  name_prefix = "e2e"
  octet_base  = 10
  octet_span  = 90
  ci_number   = var.ci_number
  public_key  = var.public_key
  base_image  = var.base_image
}
