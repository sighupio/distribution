# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

variable "hcloud_token" {
  type = string
  sensitive = true
}

variable "public_key" {
  type = string
  sensitive = true
}

variable "private_key"{
  type = string
  sensitive = true
}

variable "ci_number" {
  type = string
}