# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

{{- $version := semver .spec.distributionVersion }}

resources:
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/aws/katalog/cluster-autoscaler/v" $version.Major "." $version.Minor ".x" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/aws/katalog/load-balancer-controller" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/aws/katalog/node-termination-handler" }}
  - resources/storageclasses.yml
  - resources/snapshotclasses.yml

patchesStrategicMerge:
  - patches/cluster-autoscaler.yml
  - patches/infra-nodes.yml
  - patches/load-balancer-controller.yml
  - patches/load-balancer-controller-kapp-wait.yml
