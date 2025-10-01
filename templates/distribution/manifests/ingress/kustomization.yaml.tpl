# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
{{- if eq .spec.distribution.modules.ingress.nginx.type "dual" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/ingress/katalog/dual-nginx" }}
{{- else if eq .spec.distribution.modules.ingress.nginx.type "single" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/ingress/katalog/nginx" }}
{{- end }}

{{- if eq .spec.distribution.common.provider.type "eks" }}

{{- if eq .spec.distribution.modules.ingress.nginx.type "dual" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/ingress/katalog/external-dns/private" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/ingress/katalog/external-dns/public" }}
{{- else if eq .spec.distribution.modules.ingress.nginx.type "single" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/ingress/katalog/external-dns/public" }}
{{- end }}

{{- end }}

{{- if and (eq .spec.distribution.common.networkPoliciesEnabled true) (or (eq .spec.distribution.modules.ingress.nginx.tls.provider "certManager") (ne .spec.distribution.modules.ingress.nginx.type "none")) }}
  - policies
{{- end }}

{{- if ne .spec.distribution.modules.ingress.nginx.type "none" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/ingress/katalog/forecastle" }}
{{- end }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/ingress/katalog/cert-manager" }}

{{- if eq .spec.distribution.modules.ingress.nginx.tls.provider "certManager" }}
  - resources/cert-manager-clusterissuer.yml
{{- end }}

{{- if ne .spec.distribution.modules.ingress.nginx.type "none" }}
  - resources/ingress-infra.yml
{{- end }}

{{ if and (eq .spec.distribution.modules.ingress.nginx.tls.provider "secret") (ne .spec.distribution.modules.ingress.nginx.type "none") }}
  - secrets/tls.yml
{{- end }}

{{/* This patches section can probably be refactored */}}
patches:
{{- if and .spec.distribution.modules.ingress.certManager .spec.distribution.modules.ingress.certManager.clusterIssuer }}
  {{- if and (eq .spec.distribution.modules.ingress.nginx.tls.provider "certManager") (eq .spec.distribution.modules.ingress.certManager.clusterIssuer.type "dns01") }}
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

  {{- if ne .spec.distribution.modules.ingress.nginx.type "none" }}
  - path: patches/external-dns.yml
  {{- end }}
{{- end }}

{{ if eq .spec.distribution.modules.ingress.nginx.tls.provider "certManager" -}}
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

{{ if eq .spec.distribution.modules.ingress.nginx.tls.provider "secret" }}
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
