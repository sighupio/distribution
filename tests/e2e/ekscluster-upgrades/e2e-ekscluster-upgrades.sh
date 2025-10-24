#!/usr/bin/env sh
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -e

echo "----------------------------------------------------------------------------"
echo "Executing furyctl for the initial setup 1.32.0 with alinux2"
FURYCTL_YAML=tests/e2e/ekscluster-upgrades/manifests/furyctl-init-cluster-1.32.0-alinux2.yaml
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

  furyctl apply \
    --outdir /furyctl-outdir \
    --config "$FURYCTL_YAML" \
    --disable-analytics \
    --force all \
    --skip-vpn-confirmation \
    --no-tty
fi

echo "----------------------------------------------------------------------------"
echo "Executing nodepool migration to alinux2023 (with 1.32.0)"
FURYCTL_YAML=tests/e2e/ekscluster-upgrades/manifests/furyctl-migrate-nodepool-1.32.0-alinux2023.yaml
tests/e2e/ekscluster/replace_variables.sh --cluster-name "$CLUSTER_NAME" --furyctl-yaml "$FURYCTL_YAML"
furyctl apply \
  --outdir /furyctl-outdir \
  --config "$FURYCTL_YAML" \
  --disable-analytics \
  --force all \
  --skip-vpn-confirmation \
  --no-tty

echo "----------------------------------------------------------------------------"
echo "Executing version upgrade to 1.33.1 (with alinux2023)"
FURYCTL_YAML=tests/e2e/ekscluster-upgrades/manifests/furyctl-upgrade-version-1.33.1.yaml
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
