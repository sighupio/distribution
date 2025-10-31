#!/usr/bin/env sh
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -e

LAST_FURYCTL_YAML=tests/e2e/ekscluster/manifests/furyctl-init-cluster.yaml
tests/e2e/ekscluster/replace_variables.sh --distribution-version "$DISTRIBUTION_VERSION" --cluster-name "$CLUSTER_NAME" --furyctl-yaml "$LAST_FURYCTL_YAML"
echo "----------------------------------------------------------------------------"
echo "Executing furyctl for the initial setup"
if ! furyctl apply \
  --outdir /furyctl-outdir \
  --config "$LAST_FURYCTL_YAML" \
  --disable-analytics \
  --distro-location ./ \
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

  furyctl apply \
    --outdir /furyctl-outdir \
    --config "$LAST_FURYCTL_YAML" \
    --disable-analytics \
    --distro-location ./ \
    --force all \
    --skip-vpn-confirmation \
    --no-tty
fi
echo "$LAST_FURYCTL_YAML" > last_furyctl_yaml.txt

echo ""
echo "============================================================================"
echo "Cluster state after successful furyctl apply:"
echo "============================================================================"
echo ""
echo "--- Nodes ---"
kubectl --kubeconfig=./kubeconfig get nodes -o wide
echo ""
echo "--- All Pods ---"
kubectl --kubeconfig=./kubeconfig get pods -A -o wide
echo ""
echo "============================================================================"
echo "Testing that the components are running"
echo "============================================================================"
echo ""

bats -t tests/e2e/ekscluster/e2e-ekscluster-init-cluster.sh


LAST_FURYCTL_YAML=tests/e2e/ekscluster/manifests/furyctl-cleanup-all.yaml
tests/e2e/ekscluster/replace_variables.sh --distribution-version "$DISTRIBUTION_VERSION" --cluster-name "$CLUSTER_NAME" --furyctl-yaml "$LAST_FURYCTL_YAML"
echo "----------------------------------------------------------------------------"
echo "Executing furyctl cleanup all modules and configurations"
furyctl apply \
  --outdir /furyctl-outdir \
  --config "$LAST_FURYCTL_YAML" \
  --disable-analytics \
  --distro-location ./ \
  --force all \
  --skip-vpn-confirmation \
  --no-tty
echo "$LAST_FURYCTL_YAML" > last_furyctl_yaml.txt
bats -t tests/e2e/ekscluster/e2e-ekscluster-cleanup-all.sh
