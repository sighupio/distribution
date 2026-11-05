#!/usr/bin/env sh

# Used by furyctl diff: compares what the kapp step of scripts/apply.sh would deploy with the cluster.
# Writes out.yaml, out-filtered.yaml and kapp-diff.json in this folder. Never writes to the cluster.
# Keep the build, the filters and the kapp flags in sync with scripts/apply.sh.

set -e

kustomizebin=""
kappbin=""
kubectlbin=""
yqbin=""

$kustomizebin build --load-restrictor LoadRestrictionsNone . > out.yaml
if ! $kubectlbin get apiservice v1.monitoring.coreos.com > /dev/null 2>&1; then
  cat out.yaml | $yqbin 'select(.apiVersion != "monitoring.coreos.com/v1")' > out-filtered.yaml
  cp out-filtered.yaml out.yaml
fi

additionalKappArgs=""

"$kappbin" deploy -a kfd -n kube-system -f out.yaml $additionalKappArgs --allow-all-ns --default-label-scoping-rules=false --apply-default-update-strategy=fallback-on-replace --diff-run --json > kapp-diff.json || { cat kapp-diff.json >&2; exit 1; }
