#!/usr/bin/env sh
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -e

wait_for_eks_active() {
  cluster_name="$1"
  region="$2"
  echo "Waiting for EKS cluster ${cluster_name} to be ACTIVE with no in-progress updates..."
  while true; do
    status=$(aws eks describe-cluster --name "$cluster_name" --region "$region" --query 'cluster.status' --output text)
    updates=$(aws eks list-updates --name "$cluster_name" --region "$region" --query 'updateIds' --output text)
    if [ "$status" = "ACTIVE" ] && [ -z "$updates" ]; then
      echo "Cluster ${cluster_name} is ACTIVE with no pending updates."
      break
    fi
    echo "Cluster status: ${status}, pending updates: ${updates:-none}. Waiting 30s..."
    sleep 30
  done
}

echo "----------------------------------------------------------------------------"
echo "Executing furyctl for the initial setup 1.34.1 with alinux2023"
FURYCTL_YAML=tests/e2e/ekscluster-upgrades/manifests/furyctl-upgrade-version-1.34.1.yaml
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

echo "----------------------------------------------------------------------------"
echo "Executing version upgrade to 1.35.0 (with alinux2023)"
FURYCTL_YAML=tests/e2e/ekscluster-upgrades/manifests/furyctl-upgrade-version-1.35.0.yaml
tests/e2e/ekscluster/replace_variables.sh --cluster-name "$CLUSTER_NAME" --furyctl-yaml "$FURYCTL_YAML"
furyctl apply --upgrade \
  --outdir /furyctl-outdir \
  --config "$FURYCTL_YAML" \
  --disable-analytics \
  --distro-location ./ \
  --force upgrades \
  --skip-vpn-confirmation \
  --no-tty
echo "$FURYCTL_YAML" > last_furyctl_yaml.txt
