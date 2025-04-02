#!/usr/bin/env sh
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -e

echo "----------------------------------------------------------------------------"
echo "Executing furyctl for the initial setup 1.30.1"
/tmp/furyctl apply --config tests/e2e/kfddistribution-upgrades/furyctl-init-cluster-1.30.1.yaml --outdir "$PWD" --disable-analytics

echo "----------------------------------------------------------------------------"
echo "Executing upgrade to 1.30.2"
# we set the switch date for Loki to "tomorrow". Notice that `-d flag` does not work on Darwin, you need to use `-v +1d` instead.
yq -i ".spec.distribution.modules.logging.loki.tsdbStartDate=\"$(date -I -d '+1 day')\"" tests/e2e/kfddistribution-upgrades/furyctl-init-cluster-1.30.2.yaml
/tmp/furyctl apply --upgrade --config tests/e2e/kfddistribution-upgrades/furyctl-init-cluster-1.30.2.yaml --outdir "$PWD" --distro-location ./ --force upgrades --disable-analytics
