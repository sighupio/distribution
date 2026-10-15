#!/usr/bin/env sh

set -e


kustomizebin=""
kappbin=""
kubectlbin=""
yqbin=""
vendorPath=""

$kustomizebin build --load-restrictor LoadRestrictionsNone . > out.yaml
if echo "$OSTYPE" | grep -q '^darwin'; then
  sed -i "" 's#registry.sighup.io/fury#registry.example.com/fury#g' out.yaml
else
  sed -i 's#registry.sighup.io/fury#registry.example.com/fury#g' out.yaml
fi
if $kubectlbin get apiservice v1alpha1.monitoring.coreos.com > /dev/null 2>&1; then
  # filter out the Alertmanger Configuration custom resources from the build.
  cat out.yaml | $yqbin 'select(.kind != "AlertmanagerConfig")' > out-filtered.yaml
  cp out-filtered.yaml out.yaml
fi

if [ "$dryrun" != "" ]; then
  exit 0
fi

echo "Clean up old init jobs..."

$kubectlbin delete --ignore-not-found --wait --timeout=180s job minio-setup -n kube-system
$kubectlbin delete --ignore-not-found --wait --timeout=180s job minio-logging-buckets-setup -n logging
$kubectlbin delete --ignore-not-found --wait --timeout=180s job minio-monitoring-buckets-setup -n monitoring
$kubectlbin delete --ignore-not-found --wait --timeout=180s job minio-tracing-buckets-setup -n tracing

additionalKappArgs=""

# Retry kapp deploy once on failure
if ! "$kappbin" deploy -a kfd -n kube-system -f out.yaml $additionalKappArgs --allow-all-ns -y --default-label-scoping-rules=false --apply-default-update-strategy=fallback-on-replace --wait-timeout 120m0s --apply-timeout 120m0s --apply-concurrency 20 2>&1 ; then
  echo "kapp deploy failed at first attempt retrying a second time..."
  "$kappbin" deploy -a kfd -n kube-system -f out.yaml $additionalKappArgs --allow-all-ns -y --default-label-scoping-rules=false --apply-default-update-strategy=fallback-on-replace --wait-timeout 120m0s --apply-timeout 120m0s --apply-concurrency 20 2>&1
fi

echo "Executing cleanup migrations on values that can be nil..."

echo "Cleaning up alertmanagerconfigs..."

$kubectlbin delete --ignore-not-found --wait --timeout=180s -n monitoring alertmanagerconfigs.monitoring.coreos.com deadmanswitch
$kubectlbin delete --ignore-not-found --wait --timeout=180s -n monitoring alertmanagerconfigs.monitoring.coreos.com infra
$kubectlbin delete --ignore-not-found --wait --timeout=180s -n monitoring alertmanagerconfigs.monitoring.coreos.com k8s
$kubectlbin delete --ignore-not-found --wait --timeout=180s -n monitoring secret infra-slack-webhook
$kubectlbin delete --ignore-not-found --wait --timeout=180s -n monitoring secret k8s-slack-webhook
$kubectlbin delete --ignore-not-found --wait --timeout=180s -n monitoring secret healthchecks-webhook

echo "Apply script completed."
