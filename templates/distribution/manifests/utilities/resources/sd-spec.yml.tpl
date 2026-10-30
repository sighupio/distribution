# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- /* Non-sensitive summary of the distribution (versions, kind, module types) consumed by the */}}
{{- /* SD UI plugins, so that they do not need read access to the furyctl-config secret. */}}
{{- /* Every field is listed explicitly: never dump whole sections of .spec in here. */}}
{{- /* .kfd (kfd.yaml) is provided by furyctl; index returns nil on older furyctl versions, */}}
{{- /* in which case the module versions are empty. */}}
{{- /* It is rendered only together with Headlamp, in its namespace: Headlamp is available only */}}
{{- /* on the OnPremises and Immutable kinds. */}}
{{- $headlampType := .spec | digAny "distribution" "modules" "utilities" "headlamp" "type" "none" }}
{{- $enabled := and (eq .spec.distribution.common.provider.type "none" "immutable") (hasKeyAny .spec "kubernetes") (has $headlampType (list "token-auth" "sso")) }}
{{- if $enabled }}
{{- $kfd := index . "kfd" }}
{{- $modules := .spec.distribution.modules }}

{{- /* The template context does not carry the furyctl.yaml kind, derive it from the provider type. */}}
{{- $kind := "OnPremises" }}
{{- if eq .spec.distribution.common.provider.type "immutable" }}
{{- $kind = "Immutable" }}
{{- end }}

{{- $moduleVersions := dict }}
{{- range $name, $version := ($kfd | digAny "modules" dict) }}
{{- $_ := set $moduleVersions (toString $name) (toString $version) }}
{{- end }}

{{- /* Modules selected by a top-level `type`. When the chosen type has its own `type` */}}
{{- /* (e.g. logging.opensearch.type: single) it is reported too. */}}
{{- $moduleTypes := dict }}
{{- range $name := list "dr" "logging" "monitoring" "networking" "policy" "tracing" }}
{{- $type := toString ($modules | digAny $name "type" "none") }}
{{- $entry := dict "type" $type }}
{{- $subType := toString ($modules | digAny $name $type "type" "") }}
{{- if $subType }}
{{- $_ := set $entry $type (dict "type" $subType) }}
{{- end }}
{{- $_ := set $moduleTypes $name $entry }}
{{- end }}
{{- $_ := set $moduleTypes "auth" (dict "provider" (dict "type" (toString ($modules | digAny "auth" "provider" "type" "none")))) }}
{{- $_ := set $moduleTypes "ingress" (dict
  "nginx" (dict "type" (toString ($modules | digAny "ingress" "nginx" "type" "none")))
  "haproxy" (dict "type" (toString ($modules | digAny "ingress" "haproxy" "type" "none")))
) }}
{{- $_ := set $moduleTypes "utilities" (dict "headlamp" (dict "type" (toString $headlampType))) }}

{{- /* Links to the infrastructure UIs, shown by the SD UI next to their module. Each link is */}}
{{- /* listed under the same conditions that make the module kustomization and its */}}
{{- /* ingress-infra template render the ingress. `module` is the module name in .spec */}}
{{- /* (e.g. `policy`, not `opa`). When adding an ingress with the useful-link annotations, */}}
{{- /* add its link here too. */}}
{{- $hasAnyIngress := or (ne $modules.ingress.nginx.type "none") (ne $modules.ingress.haproxy.type "none") $modules.ingress.byoic.enabled }}
{{- $linkDefs := list }}
{{- if $modules.auth.oidcKubernetesAuth.enabled }}
{{- $linkDefs = append $linkDefs (dict "module" "auth" "package" "gangplank" "prefix" "gangplank." "name" "Gangplank") }}
{{- end }}
{{- if $hasAnyIngress }}
{{- $linkDefs = append $linkDefs (dict "module" "ingress" "package" "forecastle" "prefix" "directory." "name" "Forecastle") }}
{{- if eq $modules.logging.type "loki" "opensearch" }}
{{- if .checks.storageClassAvailable }}
{{- if eq $modules.logging.type "opensearch" }}
{{- $linkDefs = append $linkDefs (dict "module" "logging" "package" "opensearchDashboards" "prefix" "opensearch-dashboards." "name" "OpenSearch Dashboards") }}
{{- end }}
{{- $linkDefs = append $linkDefs (dict "module" "logging" "package" "minio" "prefix" "minio-logging." "name" "MinIO") }}
{{- end }}
{{- end }}
{{- if eq $modules.monitoring.type "prometheus" "mimir" }}
{{- $linkDefs = append $linkDefs (dict "module" "monitoring" "package" "grafana" "prefix" "grafana." "name" "Grafana") }}
{{- $linkDefs = append $linkDefs (dict "module" "monitoring" "package" "prometheus" "prefix" "prometheus." "name" "Prometheus") }}
{{- $linkDefs = append $linkDefs (dict "module" "monitoring" "package" "alertmanager" "prefix" "alertmanager." "name" "Alertmanager") }}
{{- if and (eq $modules.monitoring.type "mimir") (eq $modules.monitoring.mimir.backend "minio") }}
{{- $linkDefs = append $linkDefs (dict "module" "monitoring" "package" "minio" "prefix" "minio-monitoring." "name" "MinIO") }}
{{- end }}
{{- end }}
{{- if eq $modules.networking.type "calico" }}
{{- $linkDefs = append $linkDefs (dict "module" "networking" "package" "whisker" "prefix" "whisker." "name" "Whisker") }}
{{- else if eq $modules.networking.type "cilium" }}
{{- $linkDefs = append $linkDefs (dict "module" "networking" "package" "hubble" "prefix" "hubble." "name" "Hubble UI") }}
{{- end }}
{{- if eq $modules.policy.type "gatekeeper" }}
{{- $linkDefs = append $linkDefs (dict "module" "policy" "package" "gpm" "prefix" "gpm." "name" "Gatekeeper Policy Manager") }}
{{- end }}
{{- if and (eq $modules.tracing.type "tempo") .checks.storageClassAvailable (eq $modules.tracing.tempo.backend "minio") }}
{{- $linkDefs = append $linkDefs (dict "module" "tracing" "package" "minio" "prefix" "minio-tracing." "name" "MinIO") }}
{{- end }}
{{- end }}

{{- /* Same host as the "ingressHost" and "ingressHostAuth" helpers, which cannot be captured */}}
{{- /* into a variable: the override when set, otherwise the prefix plus the base domain. */}}
{{- $links := list }}
{{- range $linkDefs }}
{{- $baseDomain := $modules.ingress.baseDomain }}
{{- if eq .module "auth" }}
{{- $baseDomain = $modules.auth.baseDomain }}
{{- end }}
{{- $host := toString ($modules | digAny .module "overrides" "ingresses" .package "host" "") }}
{{- if not $host }}
{{- $host = print .prefix $baseDomain }}
{{- end }}
{{- $links = append $links (dict "module" .module "name" .name "url" (print "https://" $host)) }}
{{- end }}

{{- $info := dict
  "distributionVersion" (toString ($kfd | digAny "version" .spec.distributionVersion))
  "cluster" (dict "name" .metadata.name "kind" $kind)
  "moduleVersions" $moduleVersions
  "modules" $moduleTypes
  "links" $links
}}

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: sd-spec
  namespace: headlamp
data:
  info.json: |
{{ $info | toPrettyJson | indent 4 }}
{{- end }}
