#!/usr/bin/env sh

# Used by furyctl diff: compares what the kapp step of scripts/apply.sh would deploy with the cluster.
# Writes out.yaml and kapp-diff-<plugin name>.json in this folder. Never writes to the cluster.
# Keep the build and the kapp flags in sync with scripts/apply.sh.

set -e

kustomizebin="{{ .paths.kustomize }}"
kappbin="{{ .paths.kapp }}"

{{ if (index .spec "plugins") -}}
{{ if (index .spec.plugins "kustomize") -}}
{{ range .spec.plugins.kustomize }}

$kustomizebin build --load-restrictor LoadRestrictionsNone {{ .folder }} > out.yaml

$kappbin deploy -a kfd-plugin-{{ .name }} -n kube-system -f out.yaml --allow-all-ns --default-label-scoping-rules=false --apply-default-update-strategy=fallback-on-replace --diff-run --json > "kapp-diff-{{ .name }}.json" || { cat "kapp-diff-{{ .name }}.json" >&2; exit 1; }

{{- end }}
{{- end }}
{{- end }}
