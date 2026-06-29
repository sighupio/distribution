# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

output "vm_ip" {
  value = hcloud_server.vm.ipv4_address
}
