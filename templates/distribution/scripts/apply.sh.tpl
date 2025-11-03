#!/usr/bin/env sh

set -euo pipefail


kustomizebin="{{ .paths.kustomize }}"
kappbin="{{ .paths.kapp }}"
kubectlbin="{{ .paths.kubectl }}"
yqbin="{{ .paths.yq }}"
vendorPath="{{ .paths.vendorPath }}"

$kustomizebin build --load-restrictor LoadRestrictionsNone . > out.yaml

{{- if and (index .spec.distribution.common "registry") (ne .spec.distribution.common.registry "") }}
if echo "$OSTYPE" | grep '^darwin'; then
  sed -i "" 's#registry.sighup.io/fury#{{.spec.distribution.common.registry}}#g' out.yaml
else
  sed -i 's#registry.sighup.io/fury#{{.spec.distribution.common.registry}}#g' out.yaml
fi
{{- end }}

{{- if eq .spec.distribution.modules.monitoring.type "none" }}
if ! $kubectlbin get apiservice v1.monitoring.coreos.com; then
  cat out.yaml | $yqbin 'select(.apiVersion != "monitoring.coreos.com/v1")' > out-filtered.yaml
  cp out-filtered.yaml out.yaml
fi
{{- end }}

{{- if and (ne .spec.distribution.modules.monitoring.type "prometheusAgent") (not .spec.distribution.modules.monitoring.alertmanager.installDefaultRules) }}
if $kubectlbin get apiservice v1alpha1.monitoring.coreos.com > /dev/null 2>&1; then
  # filter out the Alertmanger Configuration custom resources from the build.
  cat out.yaml | $yqbin 'select(.kind != "AlertmanagerConfig")' > out-filtered.yaml
  cp out-filtered.yaml out.yaml
fi
{{- end }}

if [ "$dryrun" != "" ]; then
  exit 0
fi

echo "Clean up old init jobs..."

$kubectlbin delete --ignore-not-found --wait --timeout=180s job minio-setup -n kube-system
$kubectlbin delete --ignore-not-found --wait --timeout=180s job minio-logging-buckets-setup -n logging
$kubectlbin delete --ignore-not-found --wait --timeout=180s job minio-monitoring-buckets-setup -n monitoring
$kubectlbin delete --ignore-not-found --wait --timeout=180s job minio-tracing-buckets-setup -n tracing

additionalKappArgs=""

{{- if eq .spec.distribution.modules.policy.type "gatekeeper" }}
    {{- if .spec.distribution.modules.policy.gatekeeper.installDefaultPolicies }}
# We need this to tell Kapp that the CRDs will be created later by Gatekeeper
additionalKappArgs="-f ../../vendor/modules/opa/katalog/tests/kapp/exists.yaml"
    {{- end }}
{{- end }}

# Retry kapp deploy once on failure
if ! "$kappbin" deploy -a kfd -n kube-system -f out.yaml $additionalKappArgs --allow-all-ns -y --default-label-scoping-rules=false --apply-default-update-strategy=fallback-on-replace --wait-timeout 120m0s --apply-timeout 120m0s --apply-concurrency 20 2>&1 ; then
  echo "kapp failed, showing last 100 lines and retrying..."
  "$kappbin" deploy -a kfd -n kube-system -f out.yaml $additionalKappArgs --allow-all-ns -y --default-label-scoping-rules=false --apply-default-update-strategy=fallback-on-replace --wait-timeout 120m0s --apply-timeout 120m0s --apply-concurrency 20 2>&1
fi

echo "Executing cleanup migrations on values that can be nil..."

{{- if ne .spec.distribution.modules.monitoring.type "none" }}
{{- if not .spec.distribution.modules.monitoring.alertmanager.installDefaultRules }}

echo "Cleaning up alertmanagerconfigs..."

$kubectlbin delete --ignore-not-found --wait --timeout=180s -n monitoring alertmanagerconfigs.monitoring.coreos.com deadmanswitch
$kubectlbin delete --ignore-not-found --wait --timeout=180s -n monitoring alertmanagerconfigs.monitoring.coreos.com infra
$kubectlbin delete --ignore-not-found --wait --timeout=180s -n monitoring alertmanagerconfigs.monitoring.coreos.com k8s
$kubectlbin delete --ignore-not-found --wait --timeout=180s -n monitoring secret infra-slack-webhook
$kubectlbin delete --ignore-not-found --wait --timeout=180s -n monitoring secret k8s-slack-webhook
$kubectlbin delete --ignore-not-found --wait --timeout=180s -n monitoring secret healthchecks-webhook

{{- end }}
{{- end }}

{{- if eq .spec.distribution.modules.tracing.type "tempo" }}
{{- if eq .spec.distribution.modules.tracing.tempo.backend "externalEndpoint" }}

echo "Cleaning up Minio HA on tracing namespace..."

$kustomizebin build $vendorPath/modules/tracing/katalog/minio-ha > delete-tracing-minio-ha.yaml

{{- if eq .spec.distribution.modules.monitoring.type "none" }}
if ! $kubectlbin get apiservice v1.monitoring.coreos.com; then
  cat delete-tracing-minio-ha.yaml | $yqbin 'select(.apiVersion != "monitoring.coreos.com/v1")' > delete-tracing-minio-ha-filtered.yaml
  cp delete-tracing-minio-ha-filtered.yaml delete-tracing-minio-ha.yaml
fi
{{- end }}
$kubectlbin delete --ignore-not-found --wait --timeout=180s -f delete-tracing-minio-ha.yaml

{{- end }}
{{- end }}

{{- if eq .spec.distribution.modules.monitoring.type "mimir" }}
{{- if eq .spec.distribution.modules.monitoring.mimir.backend "externalEndpoint" }}

echo "Cleaning up Minio HA on monitoring namespace..."

$kustomizebin build $vendorPath/modules/monitoring/katalog/minio-ha > delete-monitoring-minio-ha.yaml

{{- if eq .spec.distribution.modules.monitoring.type "none" }}
if ! $kubectlbin get apiservice v1.monitoring.coreos.com; then
  cat delete-monitoring-minio-ha.yaml | $yqbin 'select(.apiVersion != "monitoring.coreos.com/v1")' > delete-monitoring-minio-ha-filtered.yaml
  cp delete-monitoring-minio-ha-filtered.yaml delete-monitoring-minio-ha.yaml
fi
{{- end }}
$kubectlbin delete --ignore-not-found --wait --timeout=180s -f delete-monitoring-minio-ha.yaml

{{- end }}
{{- end }}

{{- if ne .spec.distribution.modules.dr.type "none" }}
{{- if eq .spec.distribution.modules.dr.velero.backend "externalEndpoint" }}

echo "Cleaning up Minio on kube-system namespace..."

$kustomizebin build $vendorPath/modules/dr/katalog/velero/velero-on-prem/minio > delete-dr-minio.yaml

{{- if eq .spec.distribution.modules.monitoring.type "none" }}
if ! $kubectlbin get apiservice v1.monitoring.coreos.com; then
  cat delete-dr-minio.yaml | $yqbin 'select(.apiVersion != "monitoring.coreos.com/v1")' > delete-dr-minio-filtered.yaml
  cp delete-dr-minio-filtered.yaml delete-dr-minio.yaml
fi
{{- end }}
$kubectlbin delete --ignore-not-found --wait --timeout=180s -f delete-dr-minio.yaml

{{- end }}
{{- end }}


{{- if eq .spec.distribution.modules.policy.type "kyverno" }}
{{- if not .spec.distribution.modules.policy.kyverno.installDefaultPolicies }}

echo "Cleaning up Kyverno default policies..."

$kustomizebin build $vendorPath/modules/opa/katalog/kyverno/policies | $kubectlbin delete --ignore-not-found --wait --timeout=180s -f -

{{- end }}
{{- end }}


{{- if eq .spec.distribution.modules.policy.type "gatekeeper" }}
{{- if not .spec.distribution.modules.policy.gatekeeper.installDefaultPolicies }}

echo "Cleaning up Gatekeeper default policies..."

$kustomizebin build $vendorPath/modules/opa/katalog/gatekeeper/rules/constraints | $kubectlbin delete --ignore-not-found --wait --timeout=180s -f -
$kustomizebin build $vendorPath/modules/opa/katalog/gatekeeper/rules/config | $kubectlbin delete --ignore-not-found --wait --timeout=180s -f -
$kustomizebin build $vendorPath/modules/opa/katalog/gatekeeper/rules/templates | $kubectlbin delete --ignore-not-found --wait --timeout=180s -f -

{{- end }}
{{- end }}

echo "Apply script completed."
