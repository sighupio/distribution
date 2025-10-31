# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $region := "" }}
{{- if index .spec.toolsConfiguration "opentofu" }}
  {{- $region = .spec.toolsConfiguration.opentofu.state.s3.region }}
{{- else }}
  {{- $region = .spec.toolsConfiguration.terraform.state.s3.region }}
{{- end }}

module "cluster_autoscaler_iam_role" {
  source       = "{{ print .spec.distribution.common.relativeVendorPath "/modules/aws/modules/iam-for-cluster-autoscaler" }}"
  cluster_name = "{{ .metadata.name }}"
  region       = "{{ $region }}"
  {{- if and (hasKeyAny .spec.distribution.modules "aws")
   (hasKeyAny .spec.distribution.modules.aws "clusterAutoscaler")
   (hasKeyAny .spec.distribution.modules.aws.clusterAutoscaler "overrides")
   (hasKeyAny .spec.distribution.modules.aws.clusterAutoscaler.overrides "iamRoleName") }}
  autoscaler_iam_role_name_override = "{{ .spec.distribution.modules.aws.clusterAutoscaler.overrides.iamRoleName }}"
  {{- end }}
}

output "cluster_autoscaler_iam_role_arn" {
  value = module.cluster_autoscaler_iam_role.cluster_autoscaler_iam_role_arn
}
