# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

variable "name_prefix" {
  type        = string
  description = "Prefix for every libvirt resource name (pool/network/volume/domain). Distinct per pipeline (e.g. e2e vs e2eup) so install and upgrade runs never collide on the shared worker, even if they overlap."
}

variable "ci_number" {
  type        = string
  description = "Unique per-run id (DRONE_BUILD_NUMBER). Suffixes the resource names and seeds the subnet."
}

# octet_base + (ci_number % octet_span) => the third octet of the /24. Give each
# pipeline a disjoint base so their subnets can't overlap (install 10..99,
# upgrades 110..199), independent of the shared build number.
variable "octet_base" {
  type    = number
  default = 10
}

variable "octet_span" {
  type    = number
  default = 90
}

variable "public_key" {
  type        = string
  sensitive   = true
  description = "SSH public key injected into every VM via cloud-init (furyctl authenticates with the matching private key)."
}

variable "base_image" {
  type        = string
  default     = "/base/noble-100g.img"
  description = "Path (inside the runner) to the pre-seeded, 100G-resized (thin) Ubuntu 24.04 cloud image the VMs are cloned from."
}
