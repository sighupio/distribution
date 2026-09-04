# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

variable "ci_number" {
  type        = string
  description = "Unique per-run id (DRONE_BUILD_NUMBER). Suffixes the resource names and seeds the subnet."
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
