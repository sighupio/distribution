# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $infrastructureIngressClass := index .spec.distribution.modules.ingress "infrastructureIngressClass" -}}
{{- $isHaproxy := false -}}
{{- if $infrastructureIngressClass -}}
  {{- $isHaproxy = hasPrefix "haproxy" $infrastructureIngressClass -}}
{{- else if ne .spec.distribution.modules.ingress.nginx.type "none" -}}
  {{- $isHaproxy = false -}}
{{- else if ne .spec.distribution.modules.ingress.haproxy.type "none" -}}
  {{- $isHaproxy = true -}}
{{- end -}}
{{- $tlsProvider := .spec.distribution.modules.ingress.nginx.tls.provider -}}
{{- if $isHaproxy -}}
  {{- $tlsProvider = .spec.distribution.modules.ingress.haproxy.tls.provider -}}
{{- end -}}
{{- if eq .spec.distribution.modules.auth.provider.type "sso" -}}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    {{- if eq $tlsProvider "certManager" }}
    {{ template "certManagerClusterIssuer" . }}
    {{- end }}
    {{ template "byoicAnnotations" . }}
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
