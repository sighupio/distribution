# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

variable "ci_number" {
  type        = string
  description = "Unique per-run id (DRONE_BUILD_NUMBER). Names the libvirt resources and seeds the subnet."
}

variable "name_prefix" {
  type        = string
  default     = "e2eimm"
  description = "Prefix for every libvirt resource name, distinct from the on-premises pipelines (e2e, e2eup)."
}

# octet_base + (ci_number % octet_span) is the third octet of the /24.
variable "octet_base" {
  type    = number
  default = 200
}

variable "octet_span" {
  type    = number
  default = 50
}

variable "private_key_path" {
  type        = string
  default     = "/cache/ci-ssh-key"
  description = "Path to the SSH private key, as furyctl sees it. furyctl reads the public key from the same path plus .pub."
}
