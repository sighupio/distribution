#!/usr/bin/env sh

set -e

kustomizebin=""
kubectlbin=""
yqbin=""
vendorPath=""

$kustomizebin build --load-restrictor LoadRestrictionsNone . > out.yaml
if ! $kubectlbin get apiservice v1.monitoring.coreos.com; then
  cat out.yaml | $yqbin 'select(.apiVersion != "monitoring.coreos.com/v1")' > out-filtered.yaml
  cp out-filtered.yaml out.yaml
fi

# list generated with: kustomize build . | yq 'select(.kind == "CustomResourceDefinition") | .spec.group' | sort | uniq

< out.yaml $yqbin 'select(.apiVersion == "acme.cert-manager.io/*" or .apiVersion == "cert-manager.io/*" or .apiVersion == "config.gatekeeper.sh/*" or .apiVersion == "expansion.gatekeeper.sh/*" or .apiVersion == "externaldata.gatekeeper.sh/*" or .apiVersion == "forecastle.stakater.com/*" or .apiVersion == "logging-extensions.banzaicloud.io/*" or .apiVersion == "logging.banzaicloud.io/*" or .apiVersion == "monitoring.coreos.com/*" or .apiVersion == "mutations.gatekeeper.sh/*" or .apiVersion == "status.gatekeeper.sh/*" or .apiVersion == "templates.gatekeeper.sh/*" or .apiVersion == "velero.io/*")' | $kubectlbin delete --ignore-not-found --wait --timeout=180s -f -
echo "CRDs deleted"

< out.yaml $yqbin 'select(.kind == "StatefulSet")' | $kubectlbin delete --ignore-not-found --wait --timeout=180s -f -
echo "StatefulSets deleted"

$kubectlbin delete -n logging deployments -l app.kubernetes.io/instance=loki-distributed
echo "Logging loki deployments deleted"

$kubectlbin delete --ignore-not-found --wait --timeout=180s -n monitoring --all persistentvolumeclaims
echo "Monitoring PVCs deleted"

$kubectlbin delete --ignore-not-found --wait --timeout=180s -n logging --all persistentvolumeclaims
echo "Logging PVCs deleted"

$kubectlbin delete --ignore-not-found --wait --timeout=180s -n tracing --all persistentvolumeclaims
echo "Tracing PVCs deleted"

echo "Waiting 3 minutes"
sleep 180

< out.yaml $yqbin 'select(.kind == "Service" and .spec.type == "LoadBalancer")' | $kubectlbin delete --ignore-not-found --wait --timeout=180s -f - || true
echo "LoadBalancer Services deleted"

< out.yaml $yqbin 'select(.kind != "CustomResourceDefinition" and .apiVersion != "kapp.k14s.io/v1alpha1")' | $kubectlbin delete --ignore-not-found --wait --timeout=180s -f - || true
echo "Resources deleted"

< out.yaml $yqbin 'select(.kind == "CustomResourceDefinition")' | $kubectlbin delete --ignore-not-found --wait --timeout=180s -f - || true
echo "CRDs deleted"
