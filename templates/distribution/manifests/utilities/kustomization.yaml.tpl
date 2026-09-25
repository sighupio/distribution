# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $headlampType := .spec | digAny "distribution" "modules" "utilities" "headlamp" "type" "none" }}
{{- $enabled := and (eq .spec.distribution.common.provider.type "none" "immutable") (hasKeyAny .spec "kubernetes") (has $headlampType (list "token-auth" "sso")) }}
{{- if $enabled }}
{{- $vendorPrefix := print "../" .spec.distribution.common.relativeVendorPath }}

---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - {{ print $vendorPrefix "/modules/utilities/ui/katalog/headlamp" }}
{{- if eq $headlampType "token-auth" }}
  - resources/headlamp-clusterrolebinding.yml
{{- else if eq $headlampType "sso" }}
  - resources/headlamp-rbac.yml
{{- end }}
  - resources/headlamp-ingress.yml

patches:
  - path: patches/infra-nodes.yml
{{- end }}
