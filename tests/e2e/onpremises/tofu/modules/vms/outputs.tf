# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Building blocks the root modules use to render their furyctl.yaml + supporting
# files. The VM names embed the dashed IP so etcd peer URLs resolve via nip.io.
output "subnet" {
  value = local.subnet # e.g. 10.10.30
}

output "dash" {
  value = "10-10-${local.octet}" # e.g. 10-10-30, for nip.io hostnames
}

output "all_ips" {
  value = join(" ", [for k, v in local.nodes : v.ip])
}

output "controlplane_0_ip" {
  value = local.nodes["controlplane-0"].ip
}

output "worker_0_ip" {
  value = local.nodes["worker-0"].ip
}

output "nodes" {
  value = { for k, v in local.nodes : k => v.ip }
}
