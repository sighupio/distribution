# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $haproxy := index .spec.distribution.modules.ingress "haproxy" }}
{{- $haproxyType := "none" }}
{{- if and $haproxy (index $haproxy "type") }}
  {{- $haproxyType = $haproxy.type }}
{{- end }}
{{- $nginxType := .spec.distribution.modules.ingress.nginx.type }}
{{- $isDual := or (eq $nginxType "dual") (eq $haproxyType "dual") }}
{{- $isSingle := or (eq $nginxType "single") (eq $haproxyType "single") }}

{{- if and $isSingle (not $isDual) }}
module "external_dns" {
    source = "{{ print .spec.distribution.common.relativeVendorPath "/modules/ingress/modules/aws-external-dns" }}"
{{- if (.spec.distribution.modules.ingress.dns.public.create)}}
    public_zone_id = aws_route53_zone.public.zone_id
{{- else }}
    public_zone_id = data.aws_route53_zone.public.zone_id
{{- end }}
    cluster_name    = "{{ .metadata.name }}"
}

output "external_dns_public_iam_role_arn" {
    value = module.external_dns.external_dns_public_iam_role_arn
}

{{- end }}

{{- if $isDual }}

module "external_dns" {
    source = "{{ print .spec.distribution.common.relativeVendorPath "/modules/ingress/modules/aws-external-dns" }}"
{{- if (.spec.distribution.modules.ingress.dns.public.create)}}
    public_zone_id = aws_route53_zone.public.zone_id
{{- else }}
    public_zone_id = data.aws_route53_zone.public.zone_id
{{- end }}
{{- if (.spec.distribution.modules.ingress.dns.private.create)}}
    private_zone_id = aws_route53_zone.private.zone_id
    enable_private  = true
{{- else }}
    private_zone_id = data.aws_route53_zone.private.zone_id
    enable_private  = true
{{- end }}
    cluster_name    = "{{ .metadata.name }}"
}

output "external_dns_public_iam_role_arn" {
    value = module.external_dns.external_dns_public_iam_role_arn
}

output "external_dns_private_iam_role_arn" {
    value = module.external_dns.external_dns_private_iam_role_arn
}

{{- end }}
