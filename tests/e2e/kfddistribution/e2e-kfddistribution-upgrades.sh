#!/usr/bin/env sh
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -e

echo "----------------------------------------------------------------------------"
echo "Executing furyctl for the initial setup 1.31.0"
/tmp/furyctl apply --config tests/e2e/kfddistribution-upgrades/manifests/furyctl-init-cluster-1.31.0.yaml --outdir "$PWD" --disable-analytics

echo "----------------------------------------------------------------------------"
echo "Executing upgrade to 1.31.1"
/tmp/furyctl apply --upgrade --config tests/e2e/kfddistribution-upgrades/manifests/furyctl-init-cluster-1.31.1.yaml --outdir "$PWD" --distro-location ./ --force upgrades --disable-analytics
