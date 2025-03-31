#!/usr/bin/env sh

set -e

kustomizebin="{{ .paths.kustomize }}"
kubectlbin="{{ .paths.kubectl }}"
yqbin="{{ .paths.yq }}"
vendorPath="{{ .paths.vendorPath }}"

$kustomizebin build --load-restrictor LoadRestrictionsNone . > out.yaml

{{- if eq .spec.distribution.modules.monitoring.type "none" }}
if ! $kubectlbin get apiservice v1.monitoring.coreos.com; then
  cat out.yaml | $yqbin 'select(.apiVersion != "monitoring.coreos.com/v1")' > out-filtered.yaml
  cp out-filtered.yaml out.yaml
fi
{{- end }}

# list generated with: kustomize build . | yq 'select(.kind == "CustomResourceDefinition") | .spec.group' | sort | uniq
{{- if eq .spec.distribution.common.provider.type "eks" }}
< out.yaml $yqbin 'select(.kind == "Ingress")' | $kubectlbin delete --ignore-not-found --wait --timeout=180s -f -
echo "Ingresses deleted"

{{- if eq .spec.distribution.modules.ingress.dns.public.create true }}
publicHostedZones="$(aws route53 list-hosted-zones --query "HostedZones[*].[Id,Name]" --output text | grep '\t{{.spec.distribution.modules.ingress.dns.public.name}}.$' | awk '{print $1}' | cut -d'/' -f3)"
{{- else -}}
publicHostedZones=""
{{- end }}

{{- if eq .spec.distribution.modules.ingress.dns.private.create true }}
privateHostedZones="$(aws route53 list-hosted-zones --query "HostedZones[*].[Id,Name]" --output text | grep '\t{{.spec.distribution.modules.ingress.dns.private.name}}.$' | awk '{print $1}' | cut -d'/' -f3)"
{{- else -}}
privateHostedZones=""
{{- end }}

hostedZones="${publicHostedZones} ${privateHostedZones}" | tr -s ' ' | sed 's/ *$//g'

retryCounter=0

while [ "${retryCounter}" -le 10 ]; do
  if [ -z "${hostedZones}" ]; then
    break
  fi

  echo "${hostedZones}" | tr ' ' '\n' | while read -r line; do
    if [ -n "${line}" ]; then
      records="$(aws route53 list-resource-record-sets --hosted-zone-id "${line}" --query "ResourceRecordSets[?Type != 'NS' && Type != 'SOA'].Type" --output text)"

      if [ -n "${records}" ]; then
        echo "Waiting for DNS records to be deleted..."

        sleep 20
      fi
    fi
  done

  if [ "${retryCounter}" -eq 10 ]; then
    echo "Timeout waiting for DNS records to be deleted."
    exit 1
  fi

  retryCounter=$((retryCounter+1))
done

echo "Route53 records deleted"
{{- end }}

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

< out.yaml $yqbin 'select(.kind != "CustomResourceDefinition")' | $kubectlbin delete --ignore-not-found --wait --timeout=180s -f - || true
echo "Resources deleted"

< out.yaml $yqbin 'select(.kind == "CustomResourceDefinition")' | $kubectlbin delete --ignore-not-found --wait --timeout=180s -f - || true
echo "CRDs deleted"
