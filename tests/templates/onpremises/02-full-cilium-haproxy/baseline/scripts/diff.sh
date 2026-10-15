#!/usr/bin/env sh

# Used by furyctl diff: compares what the kapp step of scripts/apply.sh would deploy with the cluster.
# Writes out.yaml, out-filtered.yaml and kapp-diff*.json in this folder. Never writes to the cluster.

set -e

kustomizebin=""
kappbin=""
kubectlbin=""
yqbin=""

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

additionalKappArgs=""

"$kappbin" deploy -a kfd -n kube-system -f out.yaml $additionalKappArgs --allow-all-ns --default-label-scoping-rules=false --apply-default-update-strategy=fallback-on-replace --diff-run --json > kapp-diff.json
