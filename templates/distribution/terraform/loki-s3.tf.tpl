# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- if and (eq .spec.distribution.modules.logging.type "loki") (eq .spec.distribution.modules.logging.loki.backend "s3") }}

module "loki_s3" {
  providers = {
    aws = aws.loki
  }

  source            = "{{ print .spec.distribution.common.relativeVendorPath "/modules/logging/modules/aws-loki-s3" }}"
  bucket_name       = "{{ .spec.distribution.modules.logging.loki.s3.bucketName }}"
  oidc_provider_url = replace(data.aws_eks_cluster.this.identity.0.oidc.0.issuer, "https://", "")
  cluster_name      = "{{ .metadata.name }}"
}

output "loki_s3_iam_role_arn" {
  value = module.loki_s3.loki_iam_role_arn
}

{{- end }}
