#!/usr/bin/env sh

set -e


kustomizebin=""
kappbin=""
kubectlbin=""
yqbin=""
vendorPath=""

$kustomizebin build --load-restrictor LoadRestrictionsNone . > out.yaml
if ! $kubectlbin get apiservice v1.monitoring.coreos.com; then
  cat out.yaml | $yqbin 'select(.apiVersion != "monitoring.coreos.com/v1")' > out-filtered.yaml
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
  echo "kapp failed, showing last 100 lines and retrying..."
  "$kappbin" deploy -a kfd -n kube-system -f out.yaml $additionalKappArgs --allow-all-ns -y --default-label-scoping-rules=false --apply-default-update-strategy=fallback-on-replace --wait-timeout 120m0s --apply-timeout 120m0s --apply-concurrency 20 2>&1
fi

echo "Executing cleanup migrations on values that can be nil..."

echo "Apply script completed."
