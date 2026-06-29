# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

resource "hcloud_ssh_key" "ssh_key" {
  name       = "E2E SSH Key ${var.ci_number}"
  public_key = var.public_key
}