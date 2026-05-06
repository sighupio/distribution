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

{{/* globalIngressClass returns the ingressClassName for SD infrastructure ingresses.
     If infrastructureIngressController field is set, it identifies the controller family
     (nginx, haproxy, or custom) and applies the dual/single logic from the controller's
     type setting. Otherwise, the first in terms of priority is NGINX.
*/}}
{{ define "globalIngressClass" }}
  {{- $infrastructureIngressController := index .spec.distribution.modules.ingress "infrastructureIngressController" -}}
  {{- if $infrastructureIngressController -}}
    {{- if eq $infrastructureIngressController "nginx" -}}
      {{- if eq .spec.distribution.modules.ingress.nginx.type "dual" -}}
        {{- .type -}}
      {{- else -}}
        nginx
      {{- end -}}
    {{- else if eq $infrastructureIngressController "haproxy" -}}
      {{- if eq .spec.distribution.modules.ingress.haproxy.type "dual" -}}
        {{- if eq .type "internal" -}}
          haproxy-internal
        {{- else -}}
          haproxy-external
        {{- end -}}
      {{- else -}}
        haproxy
      {{- end -}}
    {{- else -}}
      {{- $infrastructureIngressController -}}
    {{- end -}}
  {{- else if eq .spec.distribution.modules.ingress.nginx.type "single" -}}
    nginx
  {{- else if eq .spec.distribution.modules.ingress.nginx.type "dual" -}}
    {{- .type -}}
  {{- else if eq .spec.distribution.modules.ingress.haproxy.type "single" -}}
    haproxy
  {{- else if eq .spec.distribution.modules.ingress.haproxy.type "dual" -}}
    {{- if eq .type "internal" -}}
      haproxy-internal
    {{- else -}}
      haproxy-external
    {{- end -}}
  {{- else if .spec.distribution.modules.ingress.byoic.enabled -}}
    {{- .spec.distribution.modules.ingress.byoic.ingressClass -}}
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
{{- $infrastructureIngressController := index .spec.distribution.modules.ingress "infrastructureIngressController" -}}
{{- $isHaproxy := false -}}
{{- if $infrastructureIngressController -}}
  {{- $isHaproxy = hasPrefix "haproxy" $infrastructureIngressController -}}
{{- else if ne .spec.distribution.modules.ingress.nginx.type "none" -}}
  {{- $isHaproxy = false -}}
{{- else if ne .spec.distribution.modules.ingress.haproxy.type "none" -}}
  {{- $isHaproxy = true -}}
{{- end -}}
{{- $tlsProvider := .spec.distribution.modules.ingress.nginx.tls.provider -}}
{{- if $isHaproxy -}}
  {{- $tlsProvider = .spec.distribution.modules.ingress.haproxy.tls.provider -}}
{{- end -}}
{{- if ne $tlsProvider "none" }}
  tls:
    - hosts:
      - {{ template "ingressHost" . }}
    {{- if eq $tlsProvider "certManager" }}
      secretName: {{ lower .prefix | trimSuffix "." }}-tls
    {{- end }}
{{- end }}
{{- end -}}

{{/* ingressTlsAuth { module: <module>, package: <package>, prefix: <prefix>, spec: "." } */}}
{{- define "ingressTlsAuth" -}}
{{- $infrastructureIngressController := index .spec.distribution.modules.ingress "infrastructureIngressController" -}}
{{- $isHaproxy := false -}}
{{- if $infrastructureIngressController -}}
  {{- $isHaproxy = hasPrefix "haproxy" $infrastructureIngressController -}}
{{- else if ne .spec.distribution.modules.ingress.nginx.type "none" -}}
  {{- $isHaproxy = false -}}
{{- else if ne .spec.distribution.modules.ingress.haproxy.type "none" -}}
  {{- $isHaproxy = true -}}
{{- end -}}
{{- $tlsProvider := .spec.distribution.modules.ingress.nginx.tls.provider -}}
{{- if $isHaproxy -}}
  {{- $tlsProvider = .spec.distribution.modules.ingress.haproxy.tls.provider -}}
{{- end -}}
{{- if ne $tlsProvider "none" }}
  tls:
    - hosts:
      - {{ template "ingressHostAuth" . }}
    {{- if eq $tlsProvider "certManager" }}
      secretName: {{ lower .package }}-tls
    {{- end }}
{{- end }}
{{- end -}}

{{ define "ingressAuth" }}
{{- if eq .spec.distribution.modules.auth.provider.type "basicAuth" -}}
  {{- $infrastructureIngressController := index .spec.distribution.modules.ingress "infrastructureIngressController" -}}
  {{- $isHaproxy := false -}}
  {{- if $infrastructureIngressController -}}
    {{- $isHaproxy = hasPrefix "haproxy" $infrastructureIngressController -}}
  {{- else if ne .spec.distribution.modules.ingress.nginx.type "none" -}}
    {{- $isHaproxy = false -}}
  {{- else if ne .spec.distribution.modules.ingress.haproxy.type "none" -}}
    {{- $isHaproxy = true -}}
  {{- end -}}
  {{- if $isHaproxy -}}
    {{/* HAProxy basicAuth annotations */}}
    haproxy.org/auth-type: basic-auth
    haproxy.org/auth-secret: basic-auth
    haproxy.org/auth-realm: Authentication Required
  {{- else -}}
    {{/* NGINX basicAuth annotations */}}
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
    nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required'
  {{- end -}}
{{- end -}}
{{ end }}

{{ define "certManagerClusterIssuer" }}
{{- $infrastructureIngressController := index .spec.distribution.modules.ingress "infrastructureIngressController" -}}
{{- $isHaproxy := false -}}
{{- if $infrastructureIngressController -}}
  {{- $isHaproxy = hasPrefix "haproxy" $infrastructureIngressController -}}
{{- else if ne .spec.distribution.modules.ingress.nginx.type "none" -}}
  {{- $isHaproxy = false -}}
{{- else if ne .spec.distribution.modules.ingress.haproxy.type "none" -}}
  {{- $isHaproxy = true -}}
{{- end -}}
{{- $tlsProvider := .spec.distribution.modules.ingress.nginx.tls.provider -}}
{{- if $isHaproxy -}}
  {{- $tlsProvider = .spec.distribution.modules.ingress.haproxy.tls.provider -}}
{{- end -}}
{{- if eq $tlsProvider "certManager" -}}
cert-manager.io/cluster-issuer: {{ .spec.distribution.modules.ingress.certManager.clusterIssuer.name }}
{{- end -}}
{{ end }}

{{ define "byoicAnnotations" }}
{{- $byoic := .spec.distribution.modules.ingress.byoic -}}
{{- if $byoic.enabled -}}
  {{- $commonAnnotations := default dict (index $byoic "commonAnnotations") -}}
  {{- $infrastructureIngressController := index .spec.distribution.modules.ingress "infrastructureIngressController" -}}
  {{- $isByoicActive := false -}}
  {{- if $infrastructureIngressController -}}
    {{- $isByoicActive = eq $infrastructureIngressController $byoic.ingressClass -}}
  {{- else if and (eq .spec.distribution.modules.ingress.nginx.type "none") (eq .spec.distribution.modules.ingress.haproxy.type "none") -}}
    {{- $isByoicActive = true -}}
  {{- end -}}
  {{- if $isByoicActive }}
{{- range $key, $value := $commonAnnotations }}
    {{ $key }}: {{ $value | quote }}
{{- end }}
  {{- end }}
{{- end }}
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

{{- /* controlPlaneAddress {config: <config> args: ["host"| "port"]}
   Where:
    <config> is the root of the config file (usually `.`)
    <args> is one of the following:
      - "host": to get only the host part of the controlPlaneAddress
      - "port": to get only the port part of the controlPlaneAddress
    if no args is provided, the full controlPlaneAddress ("address:port") is returned
*/}}
{{- define "controlPlaneAddress"}}
  {{- $controlPlaneAddress := "" }}
  {{- $controlPlaneHost := "" }}
  {{- $controlPlanePort := "" }}
  {{- if and (eq .config.spec.distribution.common.provider.type "none") (hasKeyAny .config.spec "kubernetes") }}
    {{- $controlPlaneAddress = .config.spec.kubernetes.controlPlaneAddress }}
  {{- else }}
    {{- fail "controlPlaneAddress is currently only available for OnPremises kind" }}
  {{- end }}
  {{- if index . "args" }}
    {{- if eq .args "host" }}
      {{- $controlPlaneHost = (split ":" $controlPlaneAddress)._0 }}
      {{- if eq $controlPlaneHost "" }}
        {{- fail "Error while calculating the Kubernetes API endpoint host." }}
      {{- end }}
      {{- $controlPlaneHost -}}
    {{- else if eq .args "port" }}
      {{- $controlPlanePort = "" }}
      {{- $addressParts := split ":" $controlPlaneAddress }}
      {{- if eq (len $addressParts) 2 }}
        {{- $controlPlanePort = $addressParts._1 }}
      {{- else }}
        {{- $controlPlanePort = "443" }}
      {{- end }}
      {{- if eq $controlPlanePort "" }}
        {{- fail "Error while calculating the Kubernetes API endpoint port." }}
      {{- end }}
      {{- $controlPlanePort -}}
    {{- else }}
      {{- fail (print "Unknown argument '" .args "' for controlPlaneAddress template.") }}
    {{- end }}
  {{- else }}
    {{- $controlPlaneAddress -}}
  {{- end }}
{{- end }}
