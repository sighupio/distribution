# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{ if and (.spec.distribution.modules.ingress.certManager) (.spec.distribution.modules.ingress.certManager.clusterIssuer) }}
{{- $tlsProvider := .spec.distribution.modules.ingress.nginx.tls.provider -}}
{{- if ne .spec.distribution.modules.ingress.haproxy.type "none" -}}
  {{- $tlsProvider = .spec.distribution.modules.ingress.haproxy.tls.provider -}}
{{- end -}}
{{ if and (eq $tlsProvider "certManager") (eq .spec.distribution.modules.ingress.certManager.clusterIssuer.type "dns01") -}}
module "cert_manager_iam_role" {
  source          = "{{ print .spec.distribution.common.relativeVendorPath "/modules/ingress/modules/aws-cert-manager" }}"
  cluster_name    = "{{ .metadata.name }}"
  {{- if (.spec.distribution.modules.ingress.dns.public.create)}}
  public_zone_id  = aws_route53_zone.public.zone_id
  {{- else }}
  public_zone_id  = data.aws_route53_zone.public.zone_id
  {{- end }}
}

output "cert_manager_iam_role_arn" {
  value = module.cert_manager_iam_role.cert_manager_iam_role_arn
}

{{ end }}

{{ end }}
