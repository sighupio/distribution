#!/usr/bin/env sh
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -e

echo "----------------------------------------------------------------------------"
echo "Executing furyctl for the initial setup"
/tmp/furyctl create cluster --config tests/e2e/kfddistribution/manifests/furyctl-init-cluster.yaml --outdir "$PWD" --distro-location ./ --force all --disable-analytics
echo "Testing that the components are running"
bats -t tests/e2e/kfddistribution/e2e-kfddistribution-init-cluster.sh

echo "----------------------------------------------------------------------------"
echo "Executing furyctl cleanup all modules and configurations"
/tmp/furyctl create cluster --config tests/e2e/kfddistribution/manifests/furyctl-cleanup-all.yaml --outdir "$PWD" --distro-location ./ --skip-deps-download --force all --disable-analytics
bats -t tests/e2e/kfddistribution/e2e-kfddistribution-cleanup-all.sh

echo "----------------------------------------------------------------------------"
echo "Resetting furyctl with the initial setup"
/tmp/furyctl create cluster --config tests/e2e/kfddistribution/manifests/furyctl-init-cluster.yaml --outdir "$PWD" --distro-location ./ --force all --disable-analytics
echo "Testing that the components are running"
bats -t tests/e2e/kfddistribution/e2e-kfddistribution-init-cluster.sh

echo "----------------------------------------------------------------------------"
echo "Executing furyctl for the secured setup"
/tmp/furyctl create cluster --config tests/e2e/kfddistribution/manifests/furyctl-init-cluster-secured.yaml --outdir "$PWD" --distro-location ./ --force all --disable-analytics
echo "Testing that the components are running"
bats -t tests/e2e/kfddistribution/e2e-kfddistribution-init-cluster.sh

echo "----------------------------------------------------------------------------"
echo "Executing furyctl cleanup all modules and configurations for the secured setup"
/tmp/furyctl create cluster --config tests/e2e/kfddistribution/manifests/furyctl-cleanup-all-secured.yaml --outdir "$PWD" --distro-location ./ --skip-deps-download --force all --disable-analytics
bats -t tests/e2e/kfddistribution/e2e-kfddistribution-cleanup-all.sh

echo "----------------------------------------------------------------------------"
echo "Resetting furyctl with the initial setup"
/tmp/furyctl create cluster --config tests/e2e/kfddistribution/manifests/furyctl-init-cluster.yaml --outdir "$PWD" --distro-location ./ --force all --disable-analytics
echo "Testing that the components are running"
bats -t tests/e2e/kfddistribution/e2e-kfddistribution-init-cluster.sh

echo "----------------------------------------------------------------------------"
echo "Executing furyctl with the tempo migration to none"
/tmp/furyctl create cluster --config tests/e2e/kfddistribution/manifests/furyctl-2-migrate-from-tempo-to-none.yaml --outdir "$PWD" --distro-location ./ --force all --skip-deps-download --disable-analytics
bats -t tests/e2e/kfddistribution/e2e-kfddistribution-2-migrate-from-tempo-to-none.sh

echo "----------------------------------------------------------------------------"
echo "Executing furyctl with the kyverno migration to none"
/tmp/furyctl create cluster --config tests/e2e/kfddistribution/manifests/furyctl-3-migrate-from-kyverno-to-none.yaml --outdir "$PWD" --distro-location ./ --force all --skip-deps-download --disable-analytics
bats -t tests/e2e/kfddistribution/e2e-kfddistribution-3-migrate-from-kyverno-to-none.sh

echo "----------------------------------------------------------------------------"
echo "Executing furyctl with the velero migration to none"
/tmp/furyctl create cluster --config tests/e2e/kfddistribution/manifests/furyctl-4-migrate-from-velero-to-none.yaml --outdir "$PWD" --distro-location ./ --force all --skip-deps-download --disable-analytics
bats -t tests/e2e/kfddistribution/e2e-kfddistribution-4-migrate-from-velero-to-none.sh

echo "----------------------------------------------------------------------------"
echo "Executing furyctl with the logging migration to none"
/tmp/furyctl create cluster --config tests/e2e/kfddistribution/manifests/furyctl-5-migrate-from-loki-to-none.yaml --outdir "$PWD" --distro-location ./ --force all --skip-deps-download --disable-analytics
bats -t tests/e2e/kfddistribution/e2e-kfddistribution-5-migrate-from-loki-to-none.sh

echo "----------------------------------------------------------------------------"
echo "Executing furyctl with the mimir migration to none"
/tmp/furyctl create cluster --config tests/e2e/kfddistribution/manifests/furyctl-6-migrate-from-mimir-to-none.yaml --outdir "$PWD" --distro-location ./ --force all --skip-deps-download --disable-analytics
bats -t tests/e2e/kfddistribution/e2e-kfddistribution-6-migrate-from-mimir-to-none.sh

echo "----------------------------------------------------------------------------"
echo "Executing furyctl with the auth basic to sso migration"
/tmp/furyctl create cluster --config tests/e2e/kfddistribution/manifests/furyctl-7-migrate-from-basicAuth-to-sso.yaml --outdir "$PWD" --distro-location ./ --force all --skip-deps-download --disable-analytics
bats -t tests/e2e/kfddistribution/e2e-kfddistribution-7-migrate-from-basicAuth-to-sso.sh

# echo "----------------------------------------------------------------------------"
# echo "Executing furyctl with the auth basic to sso migration"
# /tmp/furyctl create cluster --config tests/e2e/kfddistribution/manifests/furyctl-8-migrate-from-sso-to-none.yaml --outdir "$PWD" --distro-location ./ --force all --skip-deps-download --disable-analytics
# bats -t tests/e2e/kfddistribution/e2e-kfddistribution-8-migrate-from-sso-to-none.sh

echo "----------------------------------------------------------------------------"
echo "Executing furyctl with the nginx migration to none"
/tmp/furyctl create cluster --config tests/e2e/kfddistribution/manifests/furyctl-9-migrate-from-nginx-to-none.yaml --outdir "$PWD" --distro-location ./ --force all --skip-deps-download --disable-analytics
bats -t tests/e2e/kfddistribution/e2e-kfddistribution-9-migrate-from-nginx-to-none.sh

echo "----------------------------------------------------------------------------"
echo "Executing furyctl testing migrations from none (SAFE)"
/tmp/furyctl create cluster --config tests/e2e/kfddistribution/manifests/furyctl-10-migrate-from-none-to-safe-values.yaml --outdir "$PWD" --distro-location ./ --skip-deps-download --disable-analytics

echo "----------------------------------------------------------------------------"
echo "Executing furyctl testing kyverno uninstall policies (SAFE)"
/tmp/furyctl create cluster --config tests/e2e/kfddistribution/manifests/furyctl-11-migrate-from-kyverno-default-policies-to-disabled.yaml --outdir "$PWD" --distro-location ./ --skip-deps-download --disable-analytics
bats -t tests/e2e/kfddistribution/e2e-kfddistribution-11-migrate-from-kyverno-default-policies-to-disabled.sh

echo "----------------------------------------------------------------------------"
echo "Executing furyctl testing alertmanagerconfigs uninstall (SAFE)"
/tmp/furyctl create cluster --config tests/e2e/kfddistribution/manifests/furyctl-12-migrate-from-alertmanagerconfigs-to-disabled.yaml --outdir "$PWD" --distro-location ./ --skip-deps-download --disable-analytics
bats -t tests/e2e/kfddistribution/e2e-kfddistribution-12-migrate-from-alertmanagerconfigs-to-disabled.sh
