# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- define "iamRoleArn" -}}
  {{- $roleArn := "__UNKNOWN__" -}}
  {{- $module := index .spec.distribution.modules "aws" -}}

  {{- if $module -}}
    {{- $package := index .spec.distribution.modules.aws (index . "package") -}}

    {{- if $package -}}
      {{- $roleArn = $package.iamRoleArn -}}
    {{- end -}}
  {{- end -}}

  {{- $roleArn -}}
{{ end }}

{{- define "nodeSelector" -}}
  {{- $indent := default 8 (index . "indent") -}}

  {{- $module := index .spec.distribution.modules .module -}}

  {{- $package := dict -}}
  {{- if $module -}}
    {{- $package = index $module .package -}}
  {{- end -}}

  {{- $packageNodeSelector := dict -}}
  {{- if and ($package) (index $package "overrides") -}}
    {{- $packageNodeSelector = index $package.overrides "nodeSelector" -}}
  {{- end -}}

  {{- $moduleNodeSelector := dict -}}
  {{- if and ($module) (index $module "overrides") -}}
    {{- $moduleNodeSelector = index $module.overrides "nodeSelector" -}}
  {{- end -}}

  {{- $nodeSelector := coalesce
        $packageNodeSelector
        $moduleNodeSelector
        (index .spec.distribution.common "nodeSelector") -}}

  {{- if and (not $nodeSelector) (index . "returnEmptyInsteadOfNull") .returnEmptyInsteadOfNull -}}
  {{- "{}" | indent $indent | trim -}}
  {{- else -}}
  {{- $nodeSelector | toYaml | indent $indent | trim -}}
  {{- end -}}
{{- end -}}

{{- define "tolerations" -}}
  {{- $indent := default 8 (index . "indent") -}}

  {{- $module := index .spec.distribution.modules .module -}}

  {{- $package := dict -}}
  {{- if $module -}}
    {{- $package = index $module .package -}}
  {{- end -}}

  {{- $packageTolerations := dict -}}
  {{- if and ($package) (index $package "overrides") -}}
    {{- $packageTolerations = index $package.overrides "tolerations" -}}
  {{- end -}}

  {{- $moduleTolerations := dict -}}
  {{- if and ($module) (index $module "overrides") -}}
    {{- $moduleTolerations = index $module.overrides "tolerations" -}}
  {{- end -}}

  {{- $tolerations := coalesce
        $packageTolerations
        $moduleTolerations
        (index .spec.distribution.common "tolerations") -}}

  {{- if and (not $tolerations) (index . "returnEmptyInsteadOfNull") .returnEmptyInsteadOfNull -}}
  {{- "[]" | indent $indent | trim -}}
  {{- else -}}
  {{- $tolerations | toYaml | indent $indent | trim -}}
  {{- end -}}
{{- end -}}

{{ define "globalIngressClass" }}
  {{- if eq .spec.distribution.modules.ingress.nginx.type "single" -}}
    "nginx"
  {{- else -}}
    {{ .type }}
  {{- end -}}
{{ end }}

{{/* ingressClass { module: <module>, package: <package>, type: "internal|external", spec: "." } */}}
{{ define "ingressClass" }}
  {{- $module := index .spec.distribution.modules .module -}}
  {{- $package := index $module.overrides.ingresses .package -}}
  {{- $ingressClass := $package.ingressClass -}}
  {{- if $ingressClass -}}
    {{ $ingressClass }}
  {{- else -}}
    {{ template "globalIngressClass" (dict "spec" .spec "type" .type) }}
  {{- end -}}
{{ end }}

{{/* ingressHost { module: <module>, package: <package>, prefix: <prefix>, spec: "." } */}}
{{ define "ingressHost" }}
  {{- $module := index .spec.distribution.modules .module -}}
  {{- $package := index $module.overrides.ingresses .package -}}
  {{- $host := $package.host -}}
  {{- if $host -}}
    {{ $host }}
  {{- else -}}
    {{ print .prefix .spec.distribution.modules.ingress.baseDomain }}
  {{- end -}}
{{ end }}

{{/* ingressHostAuth { module: <module>, package: <package>, prefix: <prefix>, spec: "." } */}}
{{ define "ingressHostAuth" }}
  {{- $module := index .spec.distribution.modules .module -}}
  {{- $package := index $module.overrides.ingresses .package -}}
  {{- $host := $package.host -}}
  {{- if $host -}}
    {{ $host }}
  {{- else -}}
    {{ print .prefix .spec.distribution.modules.auth.baseDomain }}
  {{- end -}}
{{ end }}

{{/* ingressTls { module: <module>, package: <package>, prefix: <prefix>, spec: "." } */}}
{{- define "ingressTls" -}}
{{ if eq .spec.distribution.modules.ingress.nginx.tls.provider "none" -}}
  {{ else }}
  tls:
    - hosts:
      - {{ template "ingressHost" . }}
    {{- if eq .spec.distribution.modules.ingress.nginx.tls.provider "certManager" }}
      secretName: {{ lower .prefix | trimSuffix "." }}-tls
    {{- end }}
{{- end }}
{{- end -}}

{{/* ingressTlsAuth { module: <module>, package: <package>, prefix: <prefix>, spec: "." } */}}
{{- define "ingressTlsAuth" -}}
{{ if eq .spec.distribution.modules.ingress.nginx.tls.provider "none" -}}
  {{ else }}
  tls:
    - hosts:
      - {{ template "ingressHostAuth" . }}
    {{- if eq .spec.distribution.modules.ingress.nginx.tls.provider "certManager" }}
      secretName: {{ lower .package }}-tls
    {{- end }}
{{- end }}
{{- end -}}

{{ define "ingressAuth" }}
{{- if eq .spec.distribution.modules.auth.provider.type "basicAuth" -}}
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
    nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required'
{{- end -}}
{{ end }}

{{ define "certManagerClusterIssuer" }}
{{- if eq .spec.distribution.modules.ingress.nginx.tls.provider "certManager" -}}
cert-manager.io/cluster-issuer: {{ .spec.distribution.modules.ingress.certManager.clusterIssuer.name }}
{{- end -}}
{{ end }}

{{ define "alertmanagerUrl" }}
  {{- template "ingressHost" (dict "module" "monitoring" "package" "alertmanager" "prefix" "alertmanager." "spec" .) -}}
{{ end }}

{{ define "prometheusUrl" }}
  {{- template "ingressHost" (dict "module" "monitoring" "package" "prometheus" "prefix" "prometheus." "spec" .) -}}
{{ end }}

{{ define "grafanaUrl" }}
  {{- template "ingressHost" (dict "module" "monitoring" "package" "grafana" "prefix" "grafana." "spec" .) -}}
{{ end }}

{{ define "grafanaBasicAuthUrl" }}
  {{- template "ingressHost" (dict "module" "monitoring" "package" "grafanaBasicAuth" "prefix" "grafana-basic-auth." "spec" .) -}}
{{ end }}

{{ define "minioLoggingUrl" }}
  {{- template "ingressHost" (dict "module" "logging" "package" "minio" "prefix" "minio-logging." "spec" .) -}}
{{ end }}

{{ define "minioTracingUrl" }}
  {{- template "ingressHost" (dict "module" "tracing" "package" "minio" "prefix" "minio-tracing." "spec" .) -}}
{{ end }}

{{ define "minioMonitoringUrl" }}
  {{- template "ingressHost" (dict "module" "monitoring" "package" "minio" "prefix" "minio-monitoring." "spec" .) -}}
{{ end }}

{{ define "opensearchDashboardsUrl" }}
  {{- template "ingressHost" (dict "module" "logging" "package" "opensearchDashboards" "prefix" "opensearch-dashboards." "spec" .) -}}
{{ end }}

{{ define "forecastleUrl" }}
  {{- template "ingressHost" (dict "module" "ingress" "package" "forecastle" "prefix" "directory." "spec" .) -}}
{{ end }}

{{ define "cerebroUrl" }}
  {{- template "ingressHost" (dict "module" "logging" "package" "cerebro" "prefix" "cerebro." "spec" .) -}}
{{ end }}

{{ define "gpmUrl" }}
  {{- template "ingressHost" (dict "module" "policy" "package" "gpm" "prefix" "gpm." "spec" .) -}}
{{ end }}

{{ define "pomeriumUrl" }}
  {{- template "ingressHostAuth" (dict "module" "auth" "package" "pomerium" "prefix" "pomerium." "spec" .) -}}
{{ end }}

{{ define "dexUrl" }}
  {{- template "ingressHostAuth" (dict "module" "auth" "package" "dex" "prefix" "login." "spec" .) -}}
{{ end }}

{{ define "gangplankUrl" }}
  {{- template "ingressHostAuth" (dict "module" "auth" "package" "gangplank" "prefix" "gangplank." "spec" .) -}}
{{ end }}

{{ define "hubbleUrl" }}
  {{- template "ingressHost" (dict "module" "networking" "package" "hubble" "prefix" "hubble." "spec" .) -}}
{{ end }}

{{ define "docsUrl" }}
  {{- template "ingressHost" (dict "module" "docs" "package" "docs" "prefix" "docs." "spec" .) -}}
{{ end }}
