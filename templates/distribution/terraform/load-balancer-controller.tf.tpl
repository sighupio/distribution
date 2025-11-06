# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

module "load_balancer_controller_iam_role" {
  source       = "{{ print .spec.distribution.common.relativeVendorPath "/modules/aws/modules/iam-for-load-balancer-controller" }}"
  cluster_name = "{{ .metadata.name }}"
  {{- if hasField . "spec.distribution.modules.aws.loadBalancerController.overrides.iamRoleName" }}
  lb_iam_role_name_override = "{{ .spec.distribution.modules.aws.loadBalancerController.overrides.iamRoleName }}"
  {{- end }}
}

output "load_balancer_controller_iam_role_arn" {
  value = module.load_balancer_controller_iam_role.load_balancer_controller_iam_role_arn
}
