#!/usr/bin/env sh
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -e

LAST_FURYCTL_YAML=tests/e2e/ekscluster/manifests/furyctl-selfmanaged-alinux2-init-cluster.yaml
tests/e2e/ekscluster/replace_variables.sh --distribution-version "$DISTRIBUTION_VERSION" --cluster-name "$CLUSTER_NAME" --furyctl-yaml "$LAST_FURYCTL_YAML"
echo "----------------------------------------------------------------------------"
echo "Executing furyctl with self-managed nodes with alinux2"
tests/e2e/ekscluster/furyctl_apply.expect "$LAST_FURYCTL_YAML" /tmp ./
echo "$LAST_FURYCTL_YAML" > last_furyctl_yaml.txt
echo "Testing that the components are running"
bats -t tests/e2e/ekscluster/e2e-ekscluster-init-cluster.sh


LAST_FURYCTL_YAML=tests/e2e/ekscluster/manifests/furyctl-selfmanaged-alinux2-init-cluster.yaml
tests/e2e/ekscluster/replace_variables.sh --distribution-version "$DISTRIBUTION_VERSION" --cluster-name "$CLUSTER_NAME" --furyctl-yaml "$LAST_FURYCTL_YAML"
echo "----------------------------------------------------------------------------"
echo "Executing furyctl with self-managed nodes with alinux2023"
tests/e2e/ekscluster/furyctl_apply.expect "$LAST_FURYCTL_YAML" /tmp ./
echo "$LAST_FURYCTL_YAML" > last_furyctl_yaml.txt
echo "Testing that the components are running"
bats -t tests/e2e/ekscluster/e2e-ekscluster-init-cluster.sh
