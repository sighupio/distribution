#!/usr/bin/env sh

# Used by furyctl diff: compares what the kapp step of scripts/apply.sh would deploy with the cluster.
# Writes out.yaml and kapp-diff-<plugin name>.json in this folder. Never writes to the cluster.

set -e

kustomizebin="{{ .paths.kustomize }}"
kappbin="{{ .paths.kapp }}"

{{ if (index .spec "plugins") -}}
{{ if (index .spec.plugins "kustomize") -}}
{{ range .spec.plugins.kustomize }}
{{- /* name and folder go into double-quoted shell words: escape \, $, ` and ". */}}
{{- $name := .name | replace "\\" "\\\\" | replace "$" "\\$" | replace "`" "\\`" | replace "\"" "\\\"" }}
{{- $folder := .folder | replace "\\" "\\\\" | replace "$" "\\$" | replace "`" "\\`" | replace "\"" "\\\"" }}

$kustomizebin build --load-restrictor LoadRestrictionsNone "{{ $folder }}" > out.yaml

# keep in sync with scripts/apply.sh
$kappbin deploy -a "kfd-plugin-{{ $name }}" -n kube-system -f out.yaml --allow-all-ns --default-label-scoping-rules=false --apply-default-update-strategy=fallback-on-replace --diff-run --json > "kapp-diff-{{ $name }}.json"

{{- end }}
{{- end }}
{{- end }}
