# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $vendorPrefix := print "../" .spec.distribution.common.relativeVendorPath }}
{{- $haproxy := index .spec.distribution.modules.ingress "haproxy" }}
{{- $haproxyType := "none" }}
{{- if and $haproxy (index $haproxy "type") }}
  {{- $haproxyType = $haproxy.type }}
{{- end }}
{{- $nginxTls := index .spec.distribution.modules.ingress.nginx "tls" }}
{{- $tlsProvider := "none" }}
{{- if and $nginxTls (index $nginxTls "provider") }}
  {{- $tlsProvider = $nginxTls.provider }}
{{- end }}
{{- if and $haproxy (index $haproxy "type") (ne $haproxy.type "none") (index $haproxy "tls") (index $haproxy.tls "provider") }}
  {{- $tlsProvider = $haproxy.tls.provider }}
{{- end }}
{{- $byoic := index .spec.distribution.modules.ingress "byoic" }}
{{- $isBYOIC := and $byoic (index $byoic "enabled") $byoic.enabled }}
{{- $hasAnyIngress := or (ne .spec.distribution.modules.ingress.nginx.type "none") (ne $haproxyType "none") $isBYOIC }}

---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
{{- if eq .spec.distribution.modules.ingress.nginx.type "dual" }}
  - {{ print $vendorPrefix "/modules/ingress/katalog/dual-nginx" }}
{{- else if eq .spec.distribution.modules.ingress.nginx.type "single" }}
  - {{ print $vendorPrefix "/modules/ingress/katalog/nginx" }}
{{- end }}

{{/* HAProxy Ingress Controller */}}
{{- if eq $haproxyType "dual" }}
  - {{ print $vendorPrefix "/modules/ingress/katalog/haproxy/dual" }}
{{- else if eq $haproxyType "single" }}
  - {{ print $vendorPrefix "/modules/ingress/katalog/haproxy/single" }}
{{- end }}

{{/* External-dns for EKS */}}
{{- if eq .spec.distribution.common.provider.type "eks" }}
  {{- $isDual := or (eq .spec.distribution.modules.ingress.nginx.type "dual") (eq $haproxyType "dual") }}
  {{- $isSingle := and (not $isDual) (or (eq .spec.distribution.modules.ingress.nginx.type "single") (eq $haproxyType "single")) }}
  {{- if $isDual }}
  - {{ print $vendorPrefix "/modules/ingress/katalog/external-dns/private" }}
  - {{ print $vendorPrefix "/modules/ingress/katalog/external-dns/public" }}
  {{- else if $isSingle }}
  - {{ print $vendorPrefix "/modules/ingress/katalog/external-dns/public" }}
  {{- end }}
{{- end }}

{{- if and (eq .spec.distribution.common.networkPoliciesEnabled true) (or (eq $tlsProvider "certManager") $hasAnyIngress) }}
  - policies
{{- end }}

{{/* Forecastle is enabled if any ingress controller is active or BYOIC */}}
{{- if $hasAnyIngress }}
  - {{ print $vendorPrefix "/modules/ingress/katalog/forecastle" }}
{{- end }}
  - {{ print $vendorPrefix "/modules/ingress/katalog/cert-manager" }}

{{- if eq $tlsProvider "certManager" }}
  - resources/cert-manager-clusterissuer.yml
{{- end }}

{{- if $hasAnyIngress }}
  - resources/ingress-infra.yml
{{- end }}

{{- $nginxUsesSecret := and (ne .spec.distribution.modules.ingress.nginx.type "none") $nginxTls (eq $nginxTls.provider "secret") }}
{{- $haproxyUsesSecret := and (ne $haproxyType "none") $haproxy (index $haproxy "tls") (eq $haproxy.tls.provider "secret") }}
{{- if or $nginxUsesSecret $haproxyUsesSecret }}
  - secrets/tls.yml
{{- end }}

{{/* This patches section can probably be refactored */}}
patches:
{{- if and .spec.distribution.modules.ingress.certManager .spec.distribution.modules.ingress.certManager.clusterIssuer }}
  {{- if and (eq $tlsProvider "certManager") (eq .spec.distribution.modules.ingress.certManager.clusterIssuer.type "dns01") }}
  - path: patches/cert-manager-sa-route53-role-arn.yml
  {{- end }}
  - path: patches/cert-manager-kapp-group.yml
  # cert-manager is always deployed, so we need to patch at least it to include the selectors
  - path: patches/infra-nodes.yml
{{- end }}

{{- if eq .spec.distribution.common.provider.type "eks" }}
  {{- if eq .spec.distribution.modules.ingress.nginx.type "dual" }}
  - path: patches/eks-ingress-nginx-external.yml
  - path: patches/eks-ingress-nginx-internal.yml
  {{- else if eq .spec.distribution.modules.ingress.nginx.type "single" }}
  - path: patches/eks-ingress-nginx.yml
  {{- end }}

  {{/* EKS-specific patches for HAProxy */}}
  {{- if eq $haproxyType "dual" }}
  - path: patches/eks-haproxy-ingress-external.yml
  - path: patches/eks-haproxy-ingress-internal.yml
  {{- else if eq $haproxyType "single" }}
  - path: patches/eks-haproxy-ingress.yml
  {{- end }}

  {{- if or (ne .spec.distribution.modules.ingress.nginx.type "none") (ne $haproxyType "none") }}
  - path: patches/external-dns.yml
  {{- end }}
{{- end }}

{{- if eq $tlsProvider "certManager" }}
  - target:
      group: apps
      version: v1
      kind: Deployment
      name: cert-manager
      namespace: cert-manager
    patch: |-
      - op: add
        path: /spec/template/spec/containers/0/args/-
        value: "--dns01-recursive-nameservers-only"
      - op: add
        path: /spec/template/spec/containers/0/args/-
        value: "--dns01-recursive-nameservers=8.8.8.8:53,1.1.1.1:53"
{{- end }}

{{- if and (ne .spec.distribution.modules.ingress.nginx.type "none") $nginxTls (eq $nginxTls.provider "secret") }}
  {{- if eq .spec.distribution.modules.ingress.nginx.type "dual" }}
  - target:
      group: apps
      version: v1
      kind: DaemonSet
      name: ingress-nginx-controller-external
      namespace: ingress-nginx
    path: patchesJson/ingress-nginx.yml
  - target:
      group: apps
      version: v1
      kind: DaemonSet
      name: ingress-nginx-controller-internal
      namespace: ingress-nginx
    path: patchesJson/ingress-nginx.yml
  {{- else if eq .spec.distribution.modules.ingress.nginx.type "single" }}
  - target:
      group: apps
      version: v1
      kind: DaemonSet
      name: ingress-nginx-controller
      namespace: ingress-nginx
    path: patchesJson/ingress-nginx.yml
  {{- end }}
{{- end }}

{{- if and (ne $haproxyType "none") $haproxy.tls (eq $haproxy.tls.provider "secret") }}
  {{- if eq $haproxyType "dual" }}
  - target:
      group: apps
      version: v1
      kind: DaemonSet
      name: haproxy-ingress-external
      namespace: ingress-haproxy
    path: patchesJson/haproxy-ingress.yml
  - target:
      group: apps
      version: v1
      kind: DaemonSet
      name: haproxy-ingress-internal
      namespace: ingress-haproxy
    path: patchesJson/haproxy-ingress.yml
  {{- else if eq $haproxyType "single" }}
  - target:
      group: apps
      version: v1
      kind: DaemonSet
      name: haproxy-ingress
      namespace: ingress-haproxy
    path: patchesJson/haproxy-ingress.yml
  {{- end }}
{{- end }}
