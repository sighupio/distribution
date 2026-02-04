# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $vendorPrefix := print "../" .spec.distribution.common.relativeVendorPath }}
{{- $haproxyType := .spec.distribution.modules.ingress.haproxy.type }}
{{- $isBYOIC := .spec.distribution.modules.ingress.byoic.enabled }}
{{- $hasAnyIngress := or (ne .spec.distribution.modules.ingress.nginx.type "none") (ne $haproxyType "none") $isBYOIC }}

---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - {{ print $vendorPrefix "/modules/tracing/katalog/tempo-distributed" }}
{{- if eq .spec.distribution.modules.tracing.tempo.backend "minio" }}
  - {{ print $vendorPrefix "/modules/tracing/katalog/minio-ha" }}
{{- end }}
{{- if $hasAnyIngress }}
{{- if eq .spec.distribution.modules.tracing.tempo.backend "minio" }}
  - resources/ingress-infra.yml
{{- end }}
{{- end }}

{{ if eq .spec.distribution.common.networkPoliciesEnabled true }}
  - policies
{{- end }}

patches:
  - path: patches/infra-nodes.yml
{{- if eq .spec.distribution.modules.tracing.tempo.backend "minio" }}
  - path: patches/minio.yml
{{- end }}

configMapGenerator:
  - name: tempo-distributed-config
    namespace: tracing
    behavior: merge
    files:
      - patches/tempo.yaml

{{- if eq .spec.distribution.modules.tracing.tempo.backend "minio" }}
secretGenerator:
  - name: minio-tracing
    namespace: tracing
    behavior: replace
    envs:
      - patches/minio.root.env
{{- end }}
