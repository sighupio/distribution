# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $tlsProvider := .spec.distribution.modules.ingress.nginx.tls.provider -}}
{{- if ne .spec.distribution.modules.ingress.haproxy.type "none" -}}
  {{- $tlsProvider = .spec.distribution.modules.ingress.haproxy.tls.provider -}}
{{- end -}}
{{ if eq $tlsProvider "certManager" -}}

{{ if and (.spec.distribution.modules.ingress.certManager) (.spec.distribution.modules.ingress.certManager.clusterIssuer) }}

{{- $certManagerArgs := dict "module" "ingress" "package" "certManager" "spec" .spec -}}

---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: {{ .spec.distribution.modules.ingress.certManager.clusterIssuer.name }}
spec:
  acme:
    email: {{ .spec.distribution.modules.ingress.certManager.clusterIssuer.email }}
    privateKeySecretRef:
      name: {{ .spec.distribution.modules.ingress.certManager.clusterIssuer.name }}
    server: https://acme-v02.api.letsencrypt.org/directory
{{- if .spec.distribution.modules.ingress.certManager.clusterIssuer.type }}
    solvers:
{{- if eq .spec.distribution.modules.ingress.certManager.clusterIssuer.type "dns01" }}
    - dns01:
        route53:
          region: {{ .spec.distribution.modules.ingress.certManager.clusterIssuer.route53.region }}
          hostedZoneID: {{ .spec.distribution.modules.ingress.certManager.clusterIssuer.route53.hostedZoneId }}
{{ else if eq .spec.distribution.modules.ingress.certManager.clusterIssuer.type "http01" }}
{{- $nginxEnabled := ne .spec.distribution.modules.ingress.nginx.type "none" -}}
{{- $nginxCertManager := eq .spec.distribution.modules.ingress.nginx.tls.provider "certManager" -}}
{{- $haproxyEnabled := ne .spec.distribution.modules.ingress.haproxy.type "none" -}}
{{- $haproxyCertManager := eq .spec.distribution.modules.ingress.haproxy.tls.provider "certManager" -}}
{{- /* NGINX solver */}}
{{- if and $nginxEnabled $nginxCertManager }}
    - http01:
        ingress:
          class: {{ if eq .spec.distribution.modules.ingress.nginx.type "dual" }}external{{ else }}nginx{{ end }}
          podTemplate:
            metadata:
              labels:
                app: cert-manager
            spec:
              nodeSelector:
                {{- /* NOTE!: merge order is important below */}}
                {{ template "nodeSelector" ( merge (dict "returnEmptyInsteadOfNull" true) $certManagerArgs )  }}
              tolerations:
                {{ template "tolerations" ( merge (dict "indent" 16 "returnEmptyInsteadOfNull" true) $certManagerArgs ) }}
{{- end }}
{{- /* HAProxy solver */}}
{{- if and $haproxyEnabled $haproxyCertManager }}
    - http01:
        ingress:
          class: {{ if eq .spec.distribution.modules.ingress.haproxy.type "dual" }}haproxy-external{{ else }}haproxy{{ end }}
          podTemplate:
            metadata:
              labels:
                app: cert-manager
            spec:
              nodeSelector:
                {{- /* NOTE!: merge order is important below */}}
                {{ template "nodeSelector" ( merge (dict "returnEmptyInsteadOfNull" true) $certManagerArgs )  }}
              tolerations:
                {{ template "tolerations" ( merge (dict "indent" 16 "returnEmptyInsteadOfNull" true) $certManagerArgs ) }}
{{- end }}
{{- end -}}
{{- else if index .spec.distribution.modules.ingress.certManager.clusterIssuer "solvers" }}
    solvers:
      {{- .spec.distribution.modules.ingress.certManager.clusterIssuer.solvers | toYaml | nindent 6 }}
{{- end }}

{{- end -}}

{{- end -}}
