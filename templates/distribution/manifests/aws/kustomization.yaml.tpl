# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

{{- $vendorPrefix := print "../" .spec.distribution.common.relativeVendorPath }}
{{- $version := semver .spec.distributionVersion }}

resources:
  - {{ print $vendorPrefix "/modules/aws/katalog/cluster-autoscaler/v" $version.Major "." $version.Minor ".x" }}
  - {{ print $vendorPrefix "/modules/aws/katalog/load-balancer-controller" }}
  - {{ print $vendorPrefix "/modules/aws/katalog/node-termination-handler" }}
  - resources/storageclasses.yml
  - resources/snapshotclasses.yml

patches:
  - path: patches/cluster-autoscaler.yml
  - path: patches/infra-nodes.yml
  - path: patches/load-balancer-controller.yml
  - path: patches/load-balancer-controller-kapp-wait.yml
