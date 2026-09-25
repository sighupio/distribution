{{- $headlampType := .spec | digAny "distribution" "modules" "utilities" "headlamp" "type" "none" }}
{{- $enabled := and (eq .spec.distribution.common.provider.type "none" "immutable") (hasKeyAny .spec "kubernetes") (has $headlampType (list "token-auth" "sso")) }}
{{- if $enabled }}
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{ $infrastructureIngressController := index .spec.distribution.modules.ingress "infrastructureIngressController" }}
{{ $isHaproxy := false }}
{{ if $infrastructureIngressController }}
  {{ $isHaproxy = hasPrefix "haproxy" $infrastructureIngressController }}
{{ else if ne .spec.distribution.modules.ingress.nginx.type "none" }}
  {{ $isHaproxy = false }}
{{ else if ne .spec.distribution.modules.ingress.haproxy.type "none" }}
  {{ $isHaproxy = true }}
{{ end }}
{{ $tlsProvider := .spec.distribution.modules.ingress.nginx.tls.provider }}
{{ if $isHaproxy }}
  {{ $tlsProvider = .spec.distribution.modules.ingress.haproxy.tls.provider }}
{{ end }}
{{ $host := print "headlamp." .spec.distribution.modules.ingress.baseDomain }}
{{ $isSSO := eq $headlampType "sso" }}

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: headlamp
{{- if $isSSO }}
  namespace: pomerium
{{- else }}
  namespace: headlamp
{{- end }}
{{- if or (eq $tlsProvider "certManager") .spec.distribution.modules.ingress.byoic.enabled }}
  annotations:
    {{ template "certManagerClusterIssuer" . }}
    {{ template "byoicAnnotations" . }}
{{- end }}
spec:
  ingressClassName: {{ template "globalIngressClass" (dict "spec" .spec "type" "internal") }}
  rules:
    - host: {{ $host }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
{{- if $isSSO }}
                # SSO mode: Pomerium (not Headlamp directly) terminates the request, authenticates
                # the user against the IdP and injects the bearer token before proxying to Headlamp.
                name: pomerium
{{- else }}
                name: headlamp
{{- end }}
                port:
                  number: 80
{{- if ne $tlsProvider "none" }}
  tls:
    - hosts:
        - {{ $host }}
{{- if eq $tlsProvider "certManager" }}
      secretName: headlamp-tls
{{- end }}
{{- end }}
{{- end }}
