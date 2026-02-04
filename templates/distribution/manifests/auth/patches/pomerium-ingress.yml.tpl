# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $haproxy := index .spec.distribution.modules.ingress "haproxy" -}}
{{- $nginxTls := index .spec.distribution.modules.ingress.nginx "tls" -}}
{{- $tlsProvider := "none" -}}
{{- if and $nginxTls (index $nginxTls "provider") -}}
  {{- $tlsProvider = $nginxTls.provider -}}
{{- end -}}
{{- if and $haproxy (index $haproxy "type") (ne $haproxy.type "none") (index $haproxy "tls") (index $haproxy.tls "provider") -}}
  {{- $tlsProvider = $haproxy.tls.provider -}}
{{- end -}}
{{- if eq .spec.distribution.modules.auth.provider.type "sso" -}}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  {{- if eq $tlsProvider "certManager" }}
  annotations:
    {{ template "certManagerClusterIssuer" . }}
  {{- end }}
  name: pomerium
  namespace: pomerium
spec:
  # Needs to be externally available if the user wants to protect other applications in the cluster
  ingressClassName: {{ template "ingressClass" (dict "module" "auth" "package" "pomerium" "type" "external" "spec" .spec) }}
  rules:
    - host: {{ template "pomeriumUrl" .spec }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: pomerium
                port:
                  number: 80
{{- template "ingressTlsAuth" (dict "module" "auth" "package" "pomerium" "prefix" "pomerium." "spec" .spec) }}
{{- end }}
