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

{{- if eq .spec.distribution.common.networkPoliciesEnabled true }}
  - policies
{{- end }}

# We can't move the infra-nodes patch to `patches:` yet because of this bug:
# https://github.com/kubernetes-sigs/kustomize/issues/5049
# We'll need to either update to kustomize >= v5.2.1 or split the patch
# into several files, but splitting would complicate the template logic too much IMO.
patchesStrategicMerge:
  - patches/infra-nodes.yml
{{- if eq .spec.distribution.modules.policy.type "gatekeeper" }}
  - patches/gatekeeper-kapp-ordering.yml
{{- end }}
{{- if eq .spec.distribution.modules.policy.type "kyverno" }}
  - patches/kyverno-kapp-ordering.yml
{{- end }}

patches:
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
