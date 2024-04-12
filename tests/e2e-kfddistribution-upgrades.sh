#!/usr/bin/env sh
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -e

echo "----------------------------------------------------------------------------"
echo "Executing furyctl for the initial setup"
/tmp/furyctl apply --config tests/e2e/kfddistribution-upgrades/furyctl-init-cluster-1.27.4.yaml --outdir "$PWD" --disable-analytics

echo "----------------------------------------------------------------------------"
echo "Executing upgrade to the next version"
/tmp/furyctl apply --upgrade --config tests/e2e/kfddistribution-upgrades/furyctl-init-cluster-1.28.0.yaml --outdir "$PWD" --distro-location ./ --force upgrades --disable-analytics
