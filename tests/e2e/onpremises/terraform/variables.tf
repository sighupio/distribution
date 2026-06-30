# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

variable "ci_number" {
  type        = string
  description = "Unique per-run id (DRONE_BUILD_NUMBER). Names the pool/network and derives the subnet so concurrent CI runs don't collide."
}

variable "public_key" {
  type        = string
  sensitive   = true
  description = "SSH public key injected into every VM via cloud-init (furyctl authenticates with the matching private key)."
}

# Kept for drop-in compatibility with the old Hetzner var contract; unused by the
# libvirt provider (furyctl reads the private key from its keyPath directly).
variable "private_key" {
  type      = string
  sensitive = true
  default   = ""
}

variable "base_image" {
  type        = string
  default     = "/base/noble-20g.img"
  description = "Path (inside the runner) to the pre-seeded, 20G-resized Ubuntu 24.04 cloud image the VMs are cloned from."
}
