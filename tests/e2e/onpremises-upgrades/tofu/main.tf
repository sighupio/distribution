# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Upgrade pipeline infrastructure: the same VMs as the install pipeline, from the
# shared module. name_prefix "e2eup" + the 110..199 subnet range keep it disjoint
# from the install pipeline (e2e / 10..99), so the two never collide on the shared
# worker even if the gate ever lets them overlap. output.tf renders the v1.34.1
# base config and the v1.35.0 upgrade-target config.
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
  source      = "../../onpremises/tofu/modules/vms"
  name_prefix = "e2eup"
  octet_base  = 110
  octet_span  = 90
  ci_number   = var.ci_number
  public_key  = var.public_key
  base_image  = var.base_image
}
