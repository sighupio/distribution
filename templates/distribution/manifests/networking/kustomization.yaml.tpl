# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $vendorPrefix := print "../" .spec.distribution.common.relativeVendorPath }}
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
{{- if eq .spec.distribution.common.provider.type "eks" }}
  - {{ print $vendorPrefix "/modules/networking/katalog/tigera/eks-policy-only" }}
{{- end }}

{{- if eq .spec.distribution.common.provider.type "none" "immutable" }}{{/* none == on-prem, kfddistribution */}}
    {{- if eq .spec.distribution.modules.networking.type "calico" }}
  - {{ print $vendorPrefix "/modules/networking/katalog/tigera/on-prem" }}
  - resources/calico-ns.yml
      {{- /* We assume that kubeProxy is enabled by default */}}
      {{- /* The `digAny` condition needs to be specified exactly as written below to properly check if the field has been populated */}}
      {{- if not (.spec | digAny "kubernetes" "advanced" "kubeProxy" "enabled" true) }}
  - resources/tigera-kubernetes-service.yaml
      {{- end }}
    {{- end }}
    {{- if eq .spec.distribution.modules.networking.type "cilium" }}
  - {{ print $vendorPrefix "/modules/networking/katalog/cilium" }}
      {{- if ne .spec.distribution.modules.ingress.nginx.type "none" }}
  - resources/ingress-infra.yml
      {{- end }}
    {{- end }}
{{- end }}

patches:
{{- if eq .spec.distribution.common.provider.type "eks" }}
  - path: patches/tigera/infra-nodes-and-mask.yaml
{{- end }}
{{- if eq .spec.distribution.common.provider.type "none" "immutable" }}
  {{- if eq .spec.distribution.modules.networking.type "calico" }}
    {{- if eq .spec.distribution.common.provider.type "immutable" }}
  - path: patches/tigera/nfTables-dataplane.yaml
    {{- end }}
  - path: patches/tigera/infra-nodes-and-mask.yaml
  - target:
      group: apps
      version: v1
      kind: Deployment
      name: tigera-operator
      namespace: tigera-operator
    path: patches/tigera/tigera-operator-tolerations.yaml
  {{- /* We assume that kubeProxy is enabled by default */}}
  {{- /* The `digAny` condition needs to be specified exactly as written below to properly check if the field has been populated */}}
  {{- if not (.spec | digAny "kubernetes" "advanced" "kubeProxy" "enabled" true) }}
  - path: patches/tigera/ebpf-mode.yaml
  {{- end }}
  {{- end }}
  {{- if eq .spec.distribution.modules.networking.type "cilium" }}
  - path: patches/cilium/infra-nodes.yaml
  - target:
      group: apps
      version: v1
      kind: Deployment
      name: cilium-operator
      namespace: kube-system
    path: patches/cilium/cilium-operator-tolerations.yaml
    {{- /* We assume that kubeProxy is enabled by default */}}
    {{- /* The `digAny` condition needs to be specified exactly as written below to properly check if the field has been populated */}}
    {{- if not (.spec | digAny "kubernetes" "advanced" "kubeProxy" "enabled" true) }}
  - path: patches/cilium/kube-proxy-replacement.yaml
    {{- end }}
  {{- end }}
{{- end }}

{{- if eq .spec.distribution.common.provider.type "none" "immutable" }}
  {{- if eq .spec.distribution.modules.networking.type "cilium" }}
configMapGenerator:
  - behavior: merge
    envs:
    - patches/cilium/cilium-config.env
    name: cilium-config
    namespace: kube-system
  {{- end }}
{{- end }}
