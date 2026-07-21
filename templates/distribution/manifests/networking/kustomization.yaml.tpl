# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $providerType := .spec.distribution.common.provider.type }}
{{- $cni := .spec.distribution.modules.networking.type }}
{{- $vendorPrefix := print "../" .spec.distribution.common.relativeVendorPath }}
{{- $haproxyType := .spec.distribution.modules.ingress.haproxy.type }}
{{- $isBYOIC := .spec.distribution.modules.ingress.byoic.enabled }}
{{- $hasAnyIngress := or (ne .spec.distribution.modules.ingress.nginx.type "none") (ne $haproxyType "none") $isBYOIC }}
{{- /* The `digAny` condition needs to be specified exactly as written below to properly check if the field has been populated */}}
{{- $defaultKubeProxyType := "ipvs" }}
{{- if eq $providerType "immutable" }}
  {{- $defaultKubeProxyType = "nftables" }}
{{- end }}
{{- $kubeProxyType := .spec | digAny "kubernetes" "advanced" "kubeProxy" "type" $defaultKubeProxyType }}
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
{{- if eq $providerType "eks" }}
  - {{ print $vendorPrefix "/modules/networking/katalog/tigera/eks-policy-only" }}
{{- end }}

{{- if eq $providerType "none" "immutable" }}{{/* none == on-prem, kfddistribution */}}
    {{- if eq $cni "calico" }}
  - {{ print $vendorPrefix "/modules/networking/katalog/tigera/on-prem" }}
  - resources/calico-ns.yml
      {{- if eq $kubeProxyType "none" }}
  - resources/tigera-kubernetes-service.yaml
      {{- end }}
      {{- if $hasAnyIngress }}
  - resources/whisker-ingress.yml
      {{- end }}
    {{- end }}
    {{- if eq $cni "cilium" }}
  - {{ print $vendorPrefix "/modules/networking/katalog/cilium" }}
      {{- if $hasAnyIngress }}
  - resources/ingress-infra.yml
      {{- end }}
    {{- end }}
{{- end }}

{{/* The Calico policies only grant the ingress controller access to the Whisker UI; they are not
     SD network policies, so they don't depend on networkPoliciesEnabled field. */}}
{{ if and (eq $cni "calico") $hasAnyIngress }}
  - policies
{{- end }}

patches:
{{- if eq $providerType "eks" }}
  - path: patches/tigera/infra-nodes-and-mask.yaml
{{- end }}
{{- if eq $providerType "none" "immutable" }}
  {{- if eq $cni "calico" }}
  - path: patches/tigera/infra-nodes-and-mask.yaml
  - target:
      group: apps
      version: v1
      kind: Deployment
      name: tigera-operator
      namespace: tigera-operator
    path: patches/tigera/tigera-operator-tolerations.yaml
    {{- if eq $kubeProxyType "none" }}
  - path: patches/tigera/ebpf-mode.yaml
    {{- else if eq $kubeProxyType "nftables" }}
  - path: patches/tigera/nfTables-dataplane.yaml
    {{- end }}
  {{- end }}
  {{- if eq $cni "cilium" }}
  - path: patches/cilium/infra-nodes.yaml
  - target:
      group: apps
      version: v1
      kind: Deployment
      name: cilium-operator
      namespace: kube-system
    path: patches/cilium/cilium-operator-tolerations.yaml
    {{- if eq $kubeProxyType "none" }}
  - path: patches/cilium/kube-proxy-replacement.yaml
    {{- end }}
  {{- end }}
{{- end }}

{{- if eq $providerType "none" "immutable" }}
  {{- if eq $cni "cilium" }}
configMapGenerator:
  - behavior: merge
    envs:
    - patches/cilium/cilium-config.env
    name: cilium-config
    namespace: kube-system
  {{- end }}
{{- end }}
