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
publicHostedZones="$(aws route53 list-hosted-zones-by-name \
  --dns-name "{{.spec.distribution.modules.ingress.dns.public.name}}." \
  --max-items 1 \
  --query "HostedZones[0].Id" \
  --output text 2>/dev/null | cut -d'/' -f3)"
{{- else -}}
publicHostedZones=""
{{- end }}

{{- if eq .spec.distribution.modules.ingress.dns.private.create true }}
privateHostedZones="$(aws route53 list-hosted-zones-by-name \
  --dns-name "{{.spec.distribution.modules.ingress.dns.private.name}}." \
  --max-items 1 \
  --query "HostedZones[0].Id" \
  --output text 2>/dev/null | cut -d'/' -f3)"
{{- else -}}
privateHostedZones=""
{{- end }}

hostedZones=$(echo "${publicHostedZones} ${privateHostedZones}" | tr -s ' ' | sed 's/ *$//g')

# Give external-dns time to clean up records after Ingress deletion
echo "Waiting 60 seconds for external-dns to clean up DNS records..."
sleep 60

echo "Cleaning up remaining Route53 records..."
echo "${hostedZones}" | tr ' ' '\n' | while read -r line; do
  if [ -n "${line}" ]; then
    echo "Processing hosted zone: ${line}"

    # Fetch all non-NS/SOA records as JSON
    records_json=$(aws route53 list-resource-record-sets \
      --hosted-zone-id "${line}" \
      --query "ResourceRecordSets[?Type != 'NS' && Type != 'SOA']" \
      --output json)

    # Count records using yq
    num_records=$(echo "$records_json" | $yqbin -p json 'length')

    if [ "$num_records" -eq 0 ]; then
      echo "No records to delete in zone ${line}"
      continue
    fi

    echo "Deleting ${num_records} records from zone ${line}..."

    # Transform JSON array into ChangeBatch format using yq
    # Input: [{"Name": "...", "Type": "A", ...}, ...]
    # Output: {"Changes": [{"Action": "DELETE", "ResourceRecordSet": {...}}, ...]}
    change_batch=$(echo "$records_json" | $yqbin -p json -o json '[.[] | {"Action": "DELETE", "ResourceRecordSet": .}] | {"Changes": .}')

    echo "Submitting deletion request..."
    echo "$change_batch" | aws route53 change-resource-record-sets \
      --hosted-zone-id "${line}" \
      --change-batch file:///dev/stdin || echo "Warning: Failed to delete some records in zone ${line}"

    echo "Completed deletion for zone ${line}"
  fi
done

echo "Route53 records deleted"
# Capture LoadBalancer ARNs for cleanup verification
aws resourcegroupstaggingapi get-resources --region {{ .spec.region }} --resource-type-filters elasticloadbalancing:loadbalancer --tag-filters "Key=elbv2.k8s.aws/cluster,Values={{ .metadata.name }}" --query 'ResourceTagMappingList[].ResourceARN' --output text 2>/dev/null > ./lb_arns.txt || true
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

< out.yaml $yqbin 'select(.kind != "CustomResourceDefinition" and .apiVersion != "kapp.k14s.io/v1alpha1")' | $kubectlbin delete --ignore-not-found --wait --timeout=180s -f - || true
echo "Resources deleted"

< out.yaml $yqbin 'select(.kind == "CustomResourceDefinition")' | $kubectlbin delete --ignore-not-found --wait --timeout=180s -f - || true
echo "CRDs deleted"

{{- if eq .spec.distribution.common.provider.type "eks" }}
# Force delete any remaining LoadBalancers
if [ -f ./lb_arns.txt ]; then
  for arn in $(cat ./lb_arns.txt); do
    aws elbv2 describe-load-balancers --region {{ .spec.region }} --load-balancer-arns "$arn" >/dev/null 2>&1 && \
      aws elbv2 delete-load-balancer --region {{ .spec.region }} --load-balancer-arn "$arn" || true
  done
  rm -f ./lb_arns.txt
fi
{{- end }}
