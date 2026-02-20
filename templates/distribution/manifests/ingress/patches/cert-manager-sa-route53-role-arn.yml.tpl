# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{ if and (.spec.distribution.modules.ingress.certManager) (.spec.distribution.modules.ingress.certManager.clusterIssuer) }}
{{- $nginxUsesCertManager := and (ne .spec.distribution.modules.ingress.nginx.type "none") (eq .spec.distribution.modules.ingress.nginx.tls.provider "certManager") -}}
{{- $haproxyUsesCertManager := and (ne .spec.distribution.modules.ingress.haproxy.type "none") (eq .spec.distribution.modules.ingress.haproxy.tls.provider "certManager") -}}
{{- $usesCertManager := or $nginxUsesCertManager $haproxyUsesCertManager -}}
{{ if and $usesCertManager (eq .spec.distribution.modules.ingress.certManager.clusterIssuer.type "dns01") -}}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: {{ .spec.distribution.modules.ingress.certManager.clusterIssuer.route53.iamRoleArn }}
  name: cert-manager
  namespace: cert-manager
{{- end }}

{{- end }}
