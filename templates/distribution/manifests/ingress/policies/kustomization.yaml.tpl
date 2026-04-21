# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $nginxType := .spec.distribution.modules.ingress.nginx.type }}
{{- $haproxyType := .spec.distribution.modules.ingress.haproxy.type }}
{{- $nginxUsesCertManager := and (ne $nginxType "none") (eq .spec.distribution.modules.ingress.nginx.tls.provider "certManager") }}
{{- $haproxyUsesCertManager := and (ne $haproxyType "none") (eq .spec.distribution.modules.ingress.haproxy.tls.provider "certManager") }}

---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
{{- if or $nginxUsesCertManager $haproxyUsesCertManager }}
  - cert-manager
{{- end }}
{{- if ne $nginxType "none" }}
  - ingress-nginx
{{- end }}
{{- if ne $haproxyType "none" }}
  - ingress-haproxy
{{- end }}
{{- if eq .spec.distribution.common.provider.type "eks" }}
  {{- if or (ne .spec.distribution.modules.ingress.nginx.type "none") (ne $haproxyType "none") }}
  - external-dns
  {{- end }}
{{- end }}
{{- $isBYOIC := .spec.distribution.modules.ingress.byoic.enabled }}
{{- if or (ne $nginxType "none") (ne $haproxyType "none") $isBYOIC }}
  - forecastle
{{- end }}
