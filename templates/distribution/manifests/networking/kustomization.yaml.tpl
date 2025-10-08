# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $kubeProxyDisabled := and (hasKeyAny .spec "kubernetes") (hasKeyAny .spec.kubernetes "advanced") (hasKeyAny .spec.kubernetes.advanced "kubeProxy") (not (index .spec.kubernetes.advanced.kubeProxy "enabled")) }}
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
{{- if eq .spec.distribution.common.provider.type "eks" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/networking/katalog/tigera/eks-policy-only" }}
{{- end }}

{{- if eq .spec.distribution.common.provider.type "none" }}{{/* none == on-prem, kfddistribution */}}
    {{- if eq .spec.distribution.modules.networking.type "calico" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/networking/katalog/tigera/on-prem" }}
  - resources/calico-ns.yml
    {{- end }}
    {{- if eq .spec.distribution.modules.networking.type "cilium" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/networking/katalog/cilium" }}
      {{- if ne .spec.distribution.modules.ingress.nginx.type "none" }}
  - resources/ingress-infra.yml
      {{- end }}
    {{- end }}
{{- end }}

patches:
{{- if eq .spec.distribution.common.provider.type "eks" }}
  - path: patches/tigera/infra-nodes-and-mask.yaml
{{- end }}
{{- if eq .spec.distribution.common.provider.type "none" }}
  {{- if eq .spec.distribution.modules.networking.type "calico" }}
  - path: patches/tigera/infra-nodes-and-mask.yaml
  - target:
      group: apps
      version: v1
      kind: Deployment
      name: tigera-operator
      namespace: tigera-operator
    path: patches/tigera/tigera-operator-tolerations.yaml
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
    {{- if $kubeProxyDisabled }}
  - path: patches/cilium/kube-proxy-replacement.yaml
    {{- end }}
  {{- end }}
{{- end }}

{{- if eq .spec.distribution.common.provider.type "none" }}
  {{- if eq .spec.distribution.modules.networking.type "cilium" }}
configMapGenerator:
  - behavior: merge
    envs:
    - patches/cilium/cilium-config.env
    name: cilium-config
    namespace: kube-system
  {{- end }}
{{- end }}
