# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Create public DNS if nginx is single or dual and create is true

{{- if (.spec.distribution.modules.ingress.dns.public.create)}}

resource "aws_route53_zone" "public" {
  name = "{{ .spec.distribution.modules.ingress.dns.public.name }}"
}

output "aws_route53_zone_public_id" {
  value = aws_route53_zone.public.zone_id
}

output "aws_route53_zone_public_name_servers" {
  value = aws_route53_zone.public.name_servers
}

{{- end }}

# Get public DNS as data if nginx is single or dual and create is false
{{- if (not .spec.distribution.modules.ingress.dns.public.create) }}

data "aws_route53_zone" "public" {
  name = "{{ .spec.distribution.modules.ingress.dns.public.name }}"
}

output "aws_route53_zone_public_id" {
  value = data.aws_route53_zone.public.zone_id
}

{{- end }}

# Create private DNS if ingress is dual and create is true
{{- $haproxyType := .spec.distribution.modules.ingress.haproxy.type }}
{{- $nginxType := .spec.distribution.modules.ingress.nginx.type }}
{{- $isDual := or (eq $nginxType "dual") (eq $haproxyType "dual") }}
{{- if and (.spec.distribution.modules.ingress.dns.private.create) $isDual }}

resource "aws_route53_zone" "private" {
  name = "{{ .spec.distribution.modules.ingress.dns.private.name }}"
  vpc {
    vpc_id = "{{ .spec.distribution.modules.ingress.dns.private.vpcId }}"
  }
}

output "aws_route53_zone_private_id" {
  value = aws_route53_zone.private.zone_id
}

{{- end }}
# Get private DNS as data if ingress is dual and create is false
{{- if and (not .spec.distribution.modules.ingress.dns.private.create) $isDual }}

data "aws_route53_zone" "private" {
  name = "{{ .spec.distribution.modules.ingress.dns.private.name }}"
  vpc_id = "{{ .spec.distribution.modules.ingress.dns.private.vpcId }}"
}

output "aws_route53_zone_private_id" {
  value = data.aws_route53_zone.private.zone_id
}

{{- end }}
