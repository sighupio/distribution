#!/usr/bin/env sh

# Used by furyctl diff: compares what the kapp step of scripts/apply.sh would deploy with the cluster.
# Writes out.yaml, out-filtered.yaml and kapp-diff*.json in this folder. Never writes to the cluster.

set -e

kustomizebin=""
kappbin=""
kubectlbin=""
yqbin=""

$kustomizebin build --load-restrictor LoadRestrictionsNone . > out.yaml

additionalKappArgs=""

"$kappbin" deploy -a kfd -n kube-system -f out.yaml $additionalKappArgs --allow-all-ns --default-label-scoping-rules=false --apply-default-update-strategy=fallback-on-replace --diff-run --json > kapp-diff.json
