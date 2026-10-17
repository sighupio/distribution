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

{{- $info := dict
  "distributionVersion" (toString ($kfd | digAny "version" .spec.distributionVersion))
  "cluster" (dict "name" .metadata.name "kind" $kind)
  "moduleVersions" $moduleVersions
  "modules" $moduleTypes
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
