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
{{- if eq .spec.distribution.modules.policy.type "gatekeeper" }}
  - {{ print $vendorPrefix "/modules/opa/katalog/gatekeeper/core" }}
  - {{ print $vendorPrefix "/modules/opa/katalog/gatekeeper/gpm" }}
  {{- if .spec.distribution.modules.policy.gatekeeper.installDefaultPolicies }}
  - {{ print $vendorPrefix "/modules/opa/katalog/gatekeeper/rules" }}
  {{- end }}
  {{- if ne .spec.distribution.modules.monitoring.type "none" }}
  - {{ print $vendorPrefix "/modules/opa/katalog/gatekeeper/monitoring" }}
  {{- end }}
  {{- if $hasAnyIngress }}
  - resources/ingress-infra.yml
  {{- end }}
{{- end }}
{{- if eq .spec.distribution.modules.policy.type "kyverno" }}
  - {{ print $vendorPrefix "/modules/opa/katalog/kyverno/core" }}
  {{- if .spec.distribution.modules.policy.kyverno.installDefaultPolicies }}
  - {{ print $vendorPrefix "/modules/opa/katalog/kyverno/policies" }}
  {{- end }}
{{- end }}

{{- if eq .spec.distribution.common.networkPoliciesEnabled true }}
  - policies
{{- end }}

patches:
  - path: patches/infra-nodes.yml
{{- if eq .spec.distribution.modules.policy.type "kyverno" }}
  {{- if .spec.distribution.modules.policy.kyverno.additionalExcludedNamespaces }}
  - path: patches/kyverno-whitelist-namespace.yml
  {{- end }}
  {{- if .spec.distribution.modules.policy.kyverno.installDefaultPolicies }}
  - patch: |-
      - op: replace
        path: /spec/validationFailureAction
        value: {{ .spec.distribution.modules.policy.kyverno.validationFailureAction }}
    target:
      kind: ClusterPolicy
      {{- end }}
{{- end }}
{{- if eq .spec.distribution.modules.policy.type "gatekeeper" }}
  - path: patches/gatekeeper-kapp-ordering.yml
  {{- if .spec.distribution.modules.policy.gatekeeper.installDefaultPolicies }}
  - patch: |-
      - op: replace
        path: /spec/enforcementAction
        value: {{ .spec.distribution.modules.policy.gatekeeper.enforcementAction }}
    target:
      group: constraints.gatekeeper.sh
  {{- end }}
  {{- if .spec.distribution.modules.policy.gatekeeper.additionalExcludedNamespaces }}
  - target:
      group: config.gatekeeper.sh
      version: v1alpha1
      kind: Config
      name: config
    path: patches/gatekeeper-whitelist-namespace.yml
    {{- end }}
{{- end }}
