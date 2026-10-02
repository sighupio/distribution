#!/usr/bin/env sh
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -e

wait_for_eks_active() {
  cluster_name="$1"
  region="$2"
  echo "Waiting for EKS cluster ${cluster_name} to be ACTIVE..."
  while true; do
    status=$(aws eks describe-cluster --name "$cluster_name" --region "$region" --query 'cluster.status' --output text)
    if [ "$status" = "ACTIVE" ]; then
      echo "Cluster ${cluster_name} is ACTIVE."
      break
    fi
    echo "Cluster status: ${status}. Waiting 30s..."
    sleep 30
  done
}

# Dumps what EKS reports as in progress on the cluster, its node groups and addons.
# The upgrade has failed with "cluster currently has an update in progress"
# (HTTP 409) while the cluster was ACTIVE, without a known cause.
dump_eks_state() {
  cluster_name="$1"
  region="$2"
  echo "--- EKS cluster ${cluster_name} ($(date -u +%Y-%m-%dT%H:%M:%SZ)) ---"
  aws eks describe-cluster --name "$cluster_name" --region "$region" --output json || true
  echo "--- Upgrade insights ---"
  for insight_id in $(aws eks list-insights --cluster-name "$cluster_name" --region "$region" --query 'insights[].id' --output text || true); do
    aws eks describe-insight --cluster-name "$cluster_name" --region "$region" --id "$insight_id" \
      --query 'insight.{name:name,category:category,kubernetesVersion:kubernetesVersion,status:insightStatus,lastRefreshTime:lastRefreshTime}' --output json || true
  done
  echo "--- Cluster updates ---"
  for update_id in $(aws eks list-updates --name "$cluster_name" --region "$region" --query 'updateIds[]' --output text || true); do
    aws eks describe-update --name "$cluster_name" --region "$region" --update-id "$update_id" \
      --query 'update.{id:id,type:type,status:status,createdAt:createdAt,params:params,errors:errors}' --output json || true
  done
  echo "--- Node groups ---"
  for nodegroup in $(aws eks list-nodegroups --cluster-name "$cluster_name" --region "$region" --query 'nodegroups[]' --output text || true); do
    aws eks describe-nodegroup --cluster-name "$cluster_name" --region "$region" --nodegroup-name "$nodegroup" \
      --query 'nodegroup.{name:nodegroupName,status:status,version:version,releaseVersion:releaseVersion,modifiedAt:modifiedAt,health:health}' --output json || true
    for update_id in $(aws eks list-updates --name "$cluster_name" --region "$region" --nodegroup-name "$nodegroup" --query 'updateIds[]' --output text || true); do
      aws eks describe-update --name "$cluster_name" --region "$region" --nodegroup-name "$nodegroup" --update-id "$update_id" \
        --query 'update.{id:id,type:type,status:status,createdAt:createdAt,errors:errors}' --output json || true
    done
  done
  echo "--- Addons ---"
  for addon in $(aws eks list-addons --cluster-name "$cluster_name" --region "$region" --query 'addons[]' --output text || true); do
    aws eks describe-addon --cluster-name "$cluster_name" --region "$region" --addon-name "$addon" \
      --query 'addon.{name:addonName,status:status,version:addonVersion,modifiedAt:modifiedAt,health:health}' --output json || true
  done
}

# Dumps the CloudTrail events on the cluster since its creation, including the ones
# made by AWS services, to find the operation EKS considers in progress.
dump_cloudtrail_events() {
  cluster_name="$1"
  region="$2"
  created_at=$(aws eks describe-cluster --name "$cluster_name" --region "$region" --query 'cluster.createdAt' --output text || true)
  echo "--- CloudTrail events on ${cluster_name} since ${created_at} ($(date -u +%Y-%m-%dT%H:%M:%SZ)) ---"
  aws cloudtrail lookup-events --region "$region" \
    --lookup-attributes AttributeKey=ResourceName,AttributeValue="$cluster_name" \
    --start-time "$created_at" \
    --query 'reverse(sort_by(Events,&EventTime))[].[EventTime,EventSource,EventName,Username]' --output text || true
}

echo "----------------------------------------------------------------------------"
echo "Executing furyctl for the initial setup 1.35.1 with alinux2023"
FURYCTL_YAML=tests/e2e/ekscluster-upgrades/manifests/furyctl-upgrade-version-1.35.1.yaml
tests/e2e/ekscluster/replace_variables.sh --cluster-name "$CLUSTER_NAME" --furyctl-yaml "$FURYCTL_YAML"
if ! furyctl apply \
  --outdir /furyctl-outdir \
  --config "$FURYCTL_YAML" \
  --disable-analytics \
  --force all \
  --skip-vpn-confirmation \
  --no-tty; then

  echo "============================================================================"
  echo "First furyctl apply attempt failed, gathering cluster state..."
  echo "============================================================================"

  if [ -f "./kubeconfig" ]; then
    echo "--- Nodes ---"
    kubectl --kubeconfig=./kubeconfig get nodes -o wide || true
    echo ""
    echo "--- All Pods ---"
    kubectl --kubeconfig=./kubeconfig get pods -A -o wide || true
    echo ""
    echo "--- Recent Events ---"
    kubectl --kubeconfig=./kubeconfig get events -A --sort-by='.lastTimestamp' | tail -50 || true
  else
    echo "No kubeconfig found, cluster may not have been created yet"
  fi

  echo "============================================================================"
  echo "Retrying furyctl apply..."
  echo "============================================================================"

  # Remove cached binaries to avoid "text file busy" (ETXTBSY) errors when
  # the retry tries to overwrite binaries still held open from the first attempt.
  rm -rf /furyctl-outdir/.furyctl/bin/ 2>/dev/null || true

  furyctl apply \
    --outdir /furyctl-outdir \
    --config "$FURYCTL_YAML" \
    --disable-analytics \
    --force all \
    --skip-vpn-confirmation \
    --no-tty
fi

# Wait for the cluster to be ACTIVE with no pending updates before upgrading.
# Without this, UpdateClusterVersion fails with ResourceInUseException (HTTP 409)
# when an update is still in progress from the initial cluster creation.
EKS_REGION=$(yq '.spec.region' "$FURYCTL_YAML")
wait_for_eks_active "$CLUSTER_NAME" "$EKS_REGION"
dump_eks_state "$CLUSTER_NAME" "$EKS_REGION"
dump_cloudtrail_events "$CLUSTER_NAME" "$EKS_REGION"

echo "----------------------------------------------------------------------------"
echo "Executing version upgrade to 1.36.0 (with alinux2023)"
FURYCTL_YAML=tests/e2e/ekscluster-upgrades/manifests/furyctl-upgrade-version-1.36.0.yaml
tests/e2e/ekscluster/replace_variables.sh --cluster-name "$CLUSTER_NAME" --furyctl-yaml "$FURYCTL_YAML"
if ! furyctl apply --upgrade \
  --outdir /furyctl-outdir \
  --config "$FURYCTL_YAML" \
  --disable-analytics \
  --distro-location ./ \
  --force upgrades \
  --skip-vpn-confirmation \
  --no-tty; then
  echo "============================================================================"
  echo "Upgrade to 1.36.0 failed, gathering EKS state..."
  echo "============================================================================"
  dump_eks_state "$CLUSTER_NAME" "$EKS_REGION"
  dump_cloudtrail_events "$CLUSTER_NAME" "$EKS_REGION"
  # The node group reported "ClusterUnreachable: ... your cluster is going through
  # a config update" a few minutes after the 409, with no update visible from the
  # API. Watch it to measure how long that internal update lasts.
  watch_eks_internal_update "$CLUSTER_NAME" "$EKS_REGION"
  dump_eks_state "$CLUSTER_NAME" "$EKS_REGION"
  dump_cloudtrail_events "$CLUSTER_NAME" "$EKS_REGION"

  echo "============================================================================"
  echo "Retrying the upgrade to 1.36.0 (furyctl resumes from the failed phase)..."
  echo "============================================================================"
  if ! furyctl apply --upgrade \
    --outdir /furyctl-outdir \
    --config "$FURYCTL_YAML" \
    --disable-analytics \
    --distro-location ./ \
    --force upgrades \
    --skip-vpn-confirmation \
    --no-tty; then
    echo "============================================================================"
    echo "Retry of the upgrade to 1.36.0 failed too, gathering EKS state..."
    echo "============================================================================"
    dump_eks_state "$CLUSTER_NAME" "$EKS_REGION"
    dump_cloudtrail_events "$CLUSTER_NAME" "$EKS_REGION"
    exit 1
  fi
  echo "============================================================================"
  echo "WARNING: the upgrade to 1.36.0 passed only on the retry."
  echo "============================================================================"
fi
echo "$FURYCTL_YAML" > last_furyctl_yaml.txt
