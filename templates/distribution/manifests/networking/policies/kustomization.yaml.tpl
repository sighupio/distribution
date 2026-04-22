# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $nginxType := .spec.distribution.modules.ingress.nginx.type }}
{{- $haproxyType := .spec.distribution.modules.ingress.haproxy.type }}
{{- $isBYOIC := .spec.distribution.modules.ingress.byoic.enabled }}
{{- $hasAnyIngress := or (ne $nginxType "none") (ne $haproxyType "none") $isBYOIC }}

---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
{{- if and (eq .spec.distribution.modules.networking.type "calico") $hasAnyIngress }}
  - whisker
{{- end }}
