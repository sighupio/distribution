#!/usr/bin/env sh
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -e

echo "----------------------------------------------------------------------------"
echo "Executing furyctl for the initial setup 1.31.1"
FURYCTL_YAML=/drone/src/tests/e2e/ekscluster-upgrades/manifests/furyctl-init-cluster-1.31.1.yaml
/drone/src/tests/e2e/ekscluster/replace_variables.sh --cluster-name "$CLUSTER_NAME" --furyctl-yaml "$FURYCTL_YAML"
/drone/src/tests/e2e/ekscluster/furyctl_apply.expect $FURYCTL_YAML /tmp

echo "----------------------------------------------------------------------------"
echo "Executing upgrade to 1.32.0"
FURYCTL_YAML=tests/e2e/ekscluster-upgrades/manifests/furyctl-init-cluster-1.32.0.yaml
tests/e2e/ekscluster/replace_variables.sh --cluster-name "$CLUSTER_NAME" --furyctl-yaml "$FURYCTL_YAML"
tests/e2e/ekscluster-upgrades/furyctl_upgrade.expect $FURYCTL_YAML /tmp ./
