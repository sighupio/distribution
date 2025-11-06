# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

module "ebs_csi_driver_iam_role" {
  source       = "{{ print .spec.distribution.common.relativeVendorPath "/modules/aws/modules/iam-for-ebs-csi-driver" }}"
  cluster_name = "{{ .metadata.name }}"
  {{- if hasField . "spec.distribution.modules.aws.ebsCsiDriver.overrides.iamRoleName" }}
  ebs_iam_role_name_override = "{{ .spec.distribution.modules.aws.ebsCsiDriver.overrides.iamRoleName }}"
  {{- end }}
}

output "ebs_csi_driver_iam_role_arn" {
  value = module.ebs_csi_driver_iam_role.ebs_csi_driver_iam_role_arn
}
