#!/usr/bin/env sh
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -e

LAST_FURYCTL_YAML=tests/e2e/ekscluster/manifests/furyctl-init-cluster.yaml
tests/e2e/ekscluster/replace_variables.sh --distribution-version "$DISTRIBUTION_VERSION" --cluster-name "$CLUSTER_NAME" --furyctl-yaml "$LAST_FURYCTL_YAML"
echo "----------------------------------------------------------------------------"
echo "Executing furyctl for the initial setup"
tests/e2e/ekscluster/furyctl_apply.expect "$LAST_FURYCTL_YAML" /tmp ./
echo "$LAST_FURYCTL_YAML" > last_furyctl_yaml.txt
echo "Testing that the components are running"
bats -t tests/e2e/ekscluster/e2e-ekscluster-init-cluster.sh


LAST_FURYCTL_YAML=tests/e2e/ekscluster/manifests/furyctl-cleanup-all.yaml
tests/e2e/ekscluster/replace_variables.sh --distribution-version "$DISTRIBUTION_VERSION" --cluster-name "$CLUSTER_NAME" --furyctl-yaml "$LAST_FURYCTL_YAML"
echo "----------------------------------------------------------------------------"
echo "Executing furyctl cleanup all modules and configurations"
tests/e2e/ekscluster/furyctl_apply.expect "$LAST_FURYCTL_YAML" /tmp ./
echo "$LAST_FURYCTL_YAML" > last_furyctl_yaml.txt
bats -t tests/e2e/ekscluster/e2e-ekscluster-cleanup-all.sh

LAST_FURYCTL_YAML=tests/e2e/ekscluster/manifests/furyctl-init-cluster.yaml
tests/e2e/ekscluster/replace_variables.sh --distribution-version "$DISTRIBUTION_VERSION" --cluster-name "$CLUSTER_NAME" --furyctl-yaml "$LAST_FURYCTL_YAML"
echo "----------------------------------------------------------------------------"
echo "Resetting furyctl with the initial setup"
tests/e2e/ekscluster/furyctl_apply.expect "$LAST_FURYCTL_YAML" /tmp ./
echo "$LAST_FURYCTL_YAML" > last_furyctl_yaml.txt
echo "Testing that the components are running"
bats -t tests/e2e/ekscluster/e2e-ekscluster-init-cluster.sh

LAST_FURYCTL_YAML=tests/e2e/ekscluster/manifests/furyctl-2-migrate-from-tempo-to-none.yaml
tests/e2e/ekscluster/replace_variables.sh --distribution-version "$DISTRIBUTION_VERSION" --cluster-name "$CLUSTER_NAME" --furyctl-yaml "$LAST_FURYCTL_YAML"
echo "----------------------------------------------------------------------------"
echo "Executing furyctl with the tempo migration to none"
tests/e2e/ekscluster/furyctl_apply.expect "$LAST_FURYCTL_YAML" /tmp ./
echo "$LAST_FURYCTL_YAML" > last_furyctl_yaml.txt
bats -t tests/e2e/ekscluster/e2e-ekscluster-2-migrate-from-tempo-to-none.sh

LAST_FURYCTL_YAML=tests/e2e/ekscluster/manifests/furyctl-3-migrate-from-kyverno-to-none.yaml
tests/e2e/ekscluster/replace_variables.sh --distribution-version "$DISTRIBUTION_VERSION" --cluster-name "$CLUSTER_NAME" --furyctl-yaml "$LAST_FURYCTL_YAML"
echo "----------------------------------------------------------------------------"
echo "Executing furyctl with the kyverno migration to none"
tests/e2e/ekscluster/furyctl_apply.expect "$LAST_FURYCTL_YAML" /tmp ./
echo "$LAST_FURYCTL_YAML" > last_furyctl_yaml.txt
bats -t tests/e2e/ekscluster/e2e-ekscluster-3-migrate-from-kyverno-to-none.sh

LAST_FURYCTL_YAML=tests/e2e/ekscluster/manifests/furyctl-4-migrate-from-velero-to-none.yaml
tests/e2e/ekscluster/replace_variables.sh --distribution-version "$DISTRIBUTION_VERSION" --cluster-name "$CLUSTER_NAME" --furyctl-yaml "$LAST_FURYCTL_YAML"
echo "----------------------------------------------------------------------------"
echo "Executing furyctl with the velero migration to none"
tests/e2e/ekscluster/furyctl_apply.expect "$LAST_FURYCTL_YAML" /tmp ./
echo "$LAST_FURYCTL_YAML" > last_furyctl_yaml.txt
bats -t tests/e2e/ekscluster/e2e-ekscluster-4-migrate-from-velero-to-none.sh

LAST_FURYCTL_YAML=tests/e2e/ekscluster/manifests/furyctl-5-migrate-from-loki-to-none.yaml
tests/e2e/ekscluster/replace_variables.sh --distribution-version "$DISTRIBUTION_VERSION" --cluster-name "$CLUSTER_NAME" --furyctl-yaml "$LAST_FURYCTL_YAML"
echo "----------------------------------------------------------------------------"
echo "Executing furyctl with the logging migration to none"
tests/e2e/ekscluster/furyctl_apply.expect "$LAST_FURYCTL_YAML" /tmp ./
echo "$LAST_FURYCTL_YAML" > last_furyctl_yaml.txt
bats -t tests/e2e/ekscluster/e2e-ekscluster-5-migrate-from-loki-to-none.sh

LAST_FURYCTL_YAML=tests/e2e/ekscluster/manifests/furyctl-6-migrate-from-mimir-to-none.yaml
tests/e2e/ekscluster/replace_variables.sh --distribution-version "$DISTRIBUTION_VERSION" --cluster-name "$CLUSTER_NAME" --furyctl-yaml "$LAST_FURYCTL_YAML"
echo "----------------------------------------------------------------------------"
echo "Executing furyctl with the mimir migration to none"
tests/e2e/ekscluster/furyctl_apply.expect "$LAST_FURYCTL_YAML" /tmp ./
echo "$LAST_FURYCTL_YAML" > last_furyctl_yaml.txt
bats -t tests/e2e/ekscluster/e2e-ekscluster-6-migrate-from-mimir-to-none.sh

LAST_FURYCTL_YAML=tests/e2e/ekscluster/manifests/furyctl-7-migrate-from-basicAuth-to-sso.yaml
tests/e2e/ekscluster/replace_variables.sh --distribution-version "$DISTRIBUTION_VERSION" --cluster-name "$CLUSTER_NAME" --furyctl-yaml "$LAST_FURYCTL_YAML"
echo "----------------------------------------------------------------------------"
echo "Executing furyctl with the auth basic to sso migration"
tests/e2e/ekscluster/furyctl_apply.expect "$LAST_FURYCTL_YAML" /tmp ./
export KUBECONFIG=./kubeconfig
echo "$LAST_FURYCTL_YAML" > last_furyctl_yaml.txt
bats -t tests/e2e/ekscluster/e2e-ekscluster-7-migrate-from-basicAuth-to-sso.sh

#Temporary fix to delete pomerium dns 
hosted_zone_id=$(aws route53 list-hosted-zones \
--output text \
--query "HostedZones[?Name==\"$CLUSTER_NAME.e2e.ci.sighup.cc.\"].Id")

aws route53 list-resource-record-sets \
--hosted-zone-id "$hosted_zone_id" | \
jq -c '.ResourceRecordSets[]' | \
while read -r resourcerecordset; do
  type=$(echo "$resourcerecordset" | jq -r '.Type')
  
  if [ "$type" != "NS" ] && [ "$type" != "SOA" ]; then
    echo aws route53 change-resource-record-sets \
    --hosted-zone-id "$hosted_zone_id" \
    --change-batch '{"Changes":[{"Action":"DELETE","ResourceRecordSet": '"$resourcerecordset"' }]}' \
    --output text --query 'ChangeInfo.Id'
  fi
done


LAST_FURYCTL_YAML=tests/e2e/ekscluster/manifests/furyctl-8-migrate-from-sso-to-none.yaml
tests/e2e/ekscluster/replace_variables.sh --distribution-version "$DISTRIBUTION_VERSION" --cluster-name "$CLUSTER_NAME" --furyctl-yaml "$LAST_FURYCTL_YAML"
echo "----------------------------------------------------------------------------"
echo "Executing furyctl with the auth basic to sso migration"
tests/e2e/ekscluster/furyctl_apply.expect "$LAST_FURYCTL_YAML" /tmp ./
echo "$LAST_FURYCTL_YAML" > last_furyctl_yaml.txt
bats -t tests/e2e/ekscluster/e2e-ekscluster-8-migrate-from-sso-to-none.sh

LAST_FURYCTL_YAML=tests/e2e/ekscluster/manifests/furyctl-9-migrate-from-none-to-safe-values.yaml
tests/e2e/ekscluster/replace_variables.sh --distribution-version "$DISTRIBUTION_VERSION" --cluster-name "$CLUSTER_NAME" --furyctl-yaml "$LAST_FURYCTL_YAML"
echo "----------------------------------------------------------------------------"
echo "Executing furyctl testing migrations from none (SAFE)"
echo "$LAST_FURYCTL_YAML" > last_furyctl_yaml.txt
tests/e2e/ekscluster/furyctl_apply.expect "$LAST_FURYCTL_YAML" /tmp ./

LAST_FURYCTL_YAML=tests/e2e/ekscluster/manifests/furyctl-10-migrate-from-kyverno-default-policies-to-disabled.yaml
tests/e2e/ekscluster/replace_variables.sh --distribution-version "$DISTRIBUTION_VERSION" --cluster-name "$CLUSTER_NAME" --furyctl-yaml "$LAST_FURYCTL_YAML"
echo "----------------------------------------------------------------------------"
echo "Executing furyctl testing kyverno uninstall policies (SAFE)"
tests/e2e/ekscluster/furyctl_apply.expect "$LAST_FURYCTL_YAML" /tmp ./
echo "$LAST_FURYCTL_YAML" > last_furyctl_yaml.txt
bats -t tests/e2e/ekscluster/e2e-ekscluster-10-migrate-from-kyverno-default-policies-to-disabled.sh

LAST_FURYCTL_YAML=tests/e2e/ekscluster/manifests/furyctl-11-migrate-from-alertmanagerconfigs-to-disabled.yaml
tests/e2e/ekscluster/replace_variables.sh --distribution-version "$DISTRIBUTION_VERSION" --cluster-name "$CLUSTER_NAME" --furyctl-yaml "$LAST_FURYCTL_YAML"
echo "----------------------------------------------------------------------------"
echo "Executing furyctl testing alertmanagerconfigs uninstall (SAFE)"
tests/e2e/ekscluster/furyctl_apply.expect "$LAST_FURYCTL_YAML" /tmp ./
echo "$LAST_FURYCTL_YAML" > last_furyctl_yaml.txt
bats -t tests/e2e/ekscluster/e2e-ekscluster-11-migrate-from-alertmanagerconfigs-to-disabled.sh

