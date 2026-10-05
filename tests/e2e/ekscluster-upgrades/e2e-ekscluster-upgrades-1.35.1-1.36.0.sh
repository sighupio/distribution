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

EKS_REGION=$(yq '.spec.region' "$FURYCTL_YAML")
wait_for_eks_active "$CLUSTER_NAME" "$EKS_REGION"

echo "----------------------------------------------------------------------------"
echo "Executing version upgrade to 1.36.0 (with alinux2023)"
FURYCTL_YAML=tests/e2e/ekscluster-upgrades/manifests/furyctl-upgrade-version-1.36.0.yaml
tests/e2e/ekscluster/replace_variables.sh --cluster-name "$CLUSTER_NAME" --furyctl-yaml "$FURYCTL_YAML"

# About 18 minutes after its creation EKS replaces the control plane instances of
# the cluster, for about 10 minutes. Meanwhile the cluster stays ACTIVE with no
# update listed, but UpdateClusterVersion fails with ResourceInUseException
# (HTTP 409, "currently has an update in progress"), and the upgrade of the e2e
# falls in that window. Retry on that error only: furyctl resumes the upgrade
# from the failed phase.
UPGRADE_MAX_ATTEMPTS=10
UPGRADE_RETRY_DELAY=120
attempt=1
while true; do
  echo "Upgrade attempt ${attempt}/${UPGRADE_MAX_ATTEMPTS} ($(date -u +%Y-%m-%dT%H:%M:%SZ))"
  # The exit code goes through a file: the one of the pipeline is tee's.
  rm -f upgrade_exit_code.txt
  {
    exit_code=0
    furyctl apply --upgrade \
      --outdir /furyctl-outdir \
      --config "$FURYCTL_YAML" \
      --disable-analytics \
      --distro-location ./ \
      --force upgrades \
      --skip-vpn-confirmation \
      --no-tty || exit_code=$?
    echo "$exit_code" > upgrade_exit_code.txt
  } 2>&1 | tee upgrade_output.txt
  if [ "$(cat upgrade_exit_code.txt)" = "0" ]; then
    break
  fi
  if ! grep -q "Cannot VersionUpdate because cluster ${CLUSTER_NAME} currently has an update in progress" upgrade_output.txt; then
    echo "Upgrade to 1.36.0 failed."
    exit 1
  fi
  if [ "$attempt" -ge "$UPGRADE_MAX_ATTEMPTS" ]; then
    echo "Upgrade to 1.36.0 still blocked by the EKS update in progress after ${attempt} attempts."
    exit 1
  fi
  echo "EKS has an update in progress on the cluster, retrying the upgrade in ${UPGRADE_RETRY_DELAY}s..."
  sleep "$UPGRADE_RETRY_DELAY"
  attempt=$((attempt + 1))
done
echo "$FURYCTL_YAML" > last_furyctl_yaml.txt
