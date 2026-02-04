# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{ if and (.spec.distribution.modules.ingress.certManager) (.spec.distribution.modules.ingress.certManager.clusterIssuer) }}
{{- $haproxy := index .spec.distribution.modules.ingress "haproxy" -}}
{{- $nginxTls := index .spec.distribution.modules.ingress.nginx "tls" -}}
{{- $tlsProvider := "none" -}}
{{- if and $nginxTls (index $nginxTls "provider") -}}
  {{- $tlsProvider = $nginxTls.provider -}}
{{- end -}}
{{- if and $haproxy (index $haproxy "type") (ne $haproxy.type "none") (index $haproxy "tls") (index $haproxy.tls "provider") -}}
  {{- $tlsProvider = $haproxy.tls.provider -}}
{{- end -}}
{{ if and (eq $tlsProvider "certManager") (eq .spec.distribution.modules.ingress.certManager.clusterIssuer.type "dns01") -}}
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
