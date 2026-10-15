#!/usr/bin/env sh

# Used by furyctl diff: compares what the kapp step of scripts/apply.sh would deploy with the cluster.
# Writes out.yaml, out-filtered.yaml and kapp-diff*.json in this folder. Never writes to the cluster.

set -e

kustomizebin="{{ .paths.kustomize }}"
kappbin="{{ .paths.kapp }}"
kubectlbin="{{ .paths.kubectl }}"
yqbin="{{ .paths.yq }}"

{{ template "kfdBuildOutYaml" . }}

{{ template "kfdAdditionalKappArgs" . }}

"$kappbin" deploy {{ template "kfdKappApp" . }} {{ template "kfdKappStrategy" . }} --diff-run --json > kapp-diff.json
