#!/usr/bin/env sh

set -e

kustomizebin="{{ .paths.kustomize }}"
kappbin="{{ .paths.kapp }}"
kubectlbin="{{ .paths.kubectl }}"
yqbin="{{ .paths.yq }}"

{{ if (index .spec "plugins") -}}
{{ if (index .spec.plugins "kustomize") -}}
{{ range .spec.plugins.kustomize }}

echo "Deploying plugin {{ .name }}..."

$kustomizebin build --load-restrictor LoadRestrictionsNone {{ .folder }} > out.yaml

$kappbin deploy -a kfd-plugin-{{ .name }} -n kube-system -f out.yaml --allow-all-ns -y --default-label-scoping-rules=false --apply-default-update-strategy=fallback-on-replace -c

{{- end }}
{{- end }}
{{- end }}
