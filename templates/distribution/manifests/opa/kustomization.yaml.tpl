# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
{{- if eq .spec.distribution.modules.policy.type "gatekeeper" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/opa/katalog/gatekeeper/core" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/opa/katalog/gatekeeper/gpm" }}
{{- if .spec.distribution.modules.policy.gatekeeper.installDefaultPolicies }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/opa/katalog/gatekeeper/rules" }}
{{- end }}
{{- if ne .spec.distribution.modules.monitoring.type "none" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/opa/katalog/gatekeeper/monitoring" }}
{{- end }}
{{- if ne .spec.distribution.modules.ingress.nginx.type "none" }}
  - resources/ingress-infra.yml
{{- end }}
{{- end }}
{{- if eq .spec.distribution.modules.policy.type "kyverno" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/opa/katalog/kyverno/core" }}
{{- if .spec.distribution.modules.policy.kyverno.installDefaultPolicies }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/opa/katalog/kyverno/policies" }}
{{- end }}
{{- end }}

patchesStrategicMerge:
  - patches/infra-nodes.yml
{{- if .spec.distribution.modules.policy.kyverno.additionalExcludedNamespaces }}
  - patches/kyverno-whitelist-namespace.yml
{{- end }}

{{- if eq .spec.distribution.modules.policy.type "kyverno" }}
{{- if .spec.distribution.modules.policy.kyverno.installDefaultPolicies }}
patches:
  - patch: |-
      - op: replace
        path: /spec/validationFailureAction
        value: {{ .spec.distribution.modules.policy.kyverno.validationFailureAction }}
    target:
      kind: ClusterPolicy
{{- end }}
{{- end }}

{{- if eq .spec.distribution.modules.policy.type "gatekeeper" }}
{{- if .spec.distribution.modules.policy.gatekeeper.installDefaultPolicies }}
patches:
  - patch: |-
      - op: replace
        path: /spec/enforcementAction
        value: {{ .spec.distribution.modules.policy.gatekeeper.enforcementAction }}
    target:
      kind: K8sLivenessProbe
  - patch: |-
      - op: replace
        path: /spec/enforcementAction
        value: {{ .spec.distribution.modules.policy.gatekeeper.enforcementAction }}
    target:
      kind: K8sReadinessProbe
  - patch: |-
      - op: replace
        path: /spec/enforcementAction
        value: {{ .spec.distribution.modules.policy.gatekeeper.enforcementAction }}
    target:
      kind: SecurityControls
  - patch: |-
      - op: replace
        path: /spec/enforcementAction
        value: {{ .spec.distribution.modules.policy.gatekeeper.enforcementAction }}
    target:
      kind: K8sUniqueIngressHost
  - patch: |-
      - op: replace
        path: /spec/enforcementAction
        value: {{ .spec.distribution.modules.policy.gatekeeper.enforcementAction }}
    target:
      kind: K8sUniqueServiceSelector
{{- end }}
{{- end }}

{{ if .spec.distribution.modules.policy.gatekeeper.additionalExcludedNamespaces }}
patchesJson6902:
  - target:
      group: config.gatekeeper.sh
      version: v1alpha1
      kind: Config
      name: config
    path: patches/gatekeeper-whitelist-namespace.yml
{{ end }}


