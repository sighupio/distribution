#!/usr/bin/env sh

# Used by furyctl diff: compares what the kapp step of scripts/apply.sh would deploy with the cluster.
# Writes out.yaml, out-filtered.yaml and kapp-diff.json in this folder. Never writes to the cluster.
# Keep the build, the filters and the kapp flags in sync with scripts/apply.sh.

set -e

kustomizebin="{{ .paths.kustomize }}"
kappbin="{{ .paths.kapp }}"
kubectlbin="{{ .paths.kubectl }}"
yqbin="{{ .paths.yq }}"

$kustomizebin build --load-restrictor LoadRestrictionsNone . > out.yaml

{{- if and (index .spec.distribution.common "registry") (ne .spec.distribution.common.registry "") }}
if echo "$OSTYPE" | grep -q '^darwin'; then
  sed -i "" 's#registry.sighup.io/fury#{{.spec.distribution.common.registry}}#g' out.yaml
else
  sed -i 's#registry.sighup.io/fury#{{.spec.distribution.common.registry}}#g' out.yaml
fi
{{- end }}

{{- if eq .spec.distribution.modules.monitoring.type "none" }}
if ! $kubectlbin get apiservice v1.monitoring.coreos.com > /dev/null 2>&1; then
  cat out.yaml | $yqbin 'select(.apiVersion != "monitoring.coreos.com/v1")' > out-filtered.yaml
  cp out-filtered.yaml out.yaml
fi
{{- end }}

{{- if and (ne .spec.distribution.modules.monitoring.type "prometheusAgent") (not .spec.distribution.modules.monitoring.alertmanager.installDefaultRules) }}
if $kubectlbin get apiservice v1alpha1.monitoring.coreos.com > /dev/null 2>&1; then
  cat out.yaml | $yqbin 'select(.kind != "AlertmanagerConfig")' > out-filtered.yaml
  cp out-filtered.yaml out.yaml
fi
{{- end }}

additionalKappArgs=""

{{- if eq .spec.distribution.modules.policy.type "gatekeeper" }}
    {{- if .spec.distribution.modules.policy.gatekeeper.installDefaultPolicies }}
additionalKappArgs="-f ../../vendor/modules/opa/katalog/tests/kapp/exists.yaml"
    {{- end }}
{{- end }}

"$kappbin" deploy -a kfd -n kube-system -f out.yaml $additionalKappArgs --allow-all-ns --default-label-scoping-rules=false --apply-default-update-strategy=fallback-on-replace --diff-run --json > kapp-diff.json || { cat kapp-diff.json >&2; exit 1; }
