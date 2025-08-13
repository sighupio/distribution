# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

{{- $loggingType := .spec.distribution.modules.logging.type }}
{{- $customOutputs := .spec.distribution.modules.logging.customOutputs }}
{{- $loki := index .spec.distribution.modules.logging "loki" }}
{{- $fluentdReplicas := index .spec.distribution.modules.logging.operator.fluentd "replicas" }}
{{- $fluentdResources := index .spec.distribution.modules.logging.operator.fluentd "resources" }}
{{- $fluentbitResources := index .spec.distribution.modules.logging.operator.fluentbit "resources" }}

resources:
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/logging/katalog/logging-operator" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/logging/katalog/logging-operated" }}
{{- if eq $loggingType "loki" "opensearch" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/logging/katalog/minio-ha" }}
  {{- if ne .spec.distribution.modules.ingress.nginx.type "none" }}
  - resources/ingress-infra.yml
  {{- end }}
{{- end }}
{{- if eq $loggingType "opensearch" "customOutputs" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/logging/katalog/configs/audit" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/logging/katalog/configs/events" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/logging/katalog/configs/infra" }}
  {{- if ne .spec.distribution.modules.ingress.nginx.type "none" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/logging/katalog/configs/ingress-nginx" }}
  {{- end }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/logging/katalog/configs/kubernetes" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/logging/katalog/configs/systemd" }}
  {{- if eq $loggingType "opensearch" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/logging/katalog/opensearch-dashboards" }}
    {{- if eq .spec.distribution.modules.logging.opensearch.type "single" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/logging/katalog/opensearch-single" }}
    {{- else if eq .spec.distribution.modules.logging.opensearch.type "triple" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/logging/katalog/opensearch-triple" }}
    {{- end }}
  {{- end }}
{{- else if eq $loggingType "loki" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/logging/katalog/loki-configs/audit" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/logging/katalog/loki-configs/events" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/logging/katalog/loki-configs/infra" }}
  {{- if ne .spec.distribution.modules.ingress.nginx.type "none" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/logging/katalog/loki-configs/ingress-nginx" }}
  {{- end }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/logging/katalog/loki-configs/kubernetes" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/logging/katalog/loki-configs/systemd" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/logging/katalog/loki-distributed" }}
{{- end }}

{{- if eq .spec.distribution.common.networkPoliciesEnabled true }}
  - policies
{{- end }}

patches:
  - path: patches/infra-nodes.yml
{{- if or $fluentdReplicas $fluentdResources $fluentbitResources }}
  - path: patches/logging-operated-resources.yaml
{{- end }}
{{- if eq $loggingType "opensearch" "loki" }}
  - path: patches/minio.yml
  {{- if eq $loggingType "opensearch" }}
  - path: patches/opensearch.yml
  {{- /* The patch file below can be empty when loki resources is not defined but kustomize 5.6.0 (our current version) fails when a patch file is empty, so we need to apply it conditionally. */ -}}
  {{- else if hasKeyAny $loki "resources" }}
  - path: patches/loki-resources.yml
  {{- end }}
{{- end }}
{{- if eq $loggingType "customOutputs" }}
  - target:
      kind: Output
      group: logging.banzaicloud.io
      version: v1beta1
      name: audit
    patch: |-
      - op: replace
        path: /spec
        value:
{{ $customOutputs.audit | indent 10 }}
  - target:
      kind: Output
      group: logging.banzaicloud.io
      version: v1beta1
      name: events
    patch: |-
      - op: replace
        path: /spec
        value:
{{ $customOutputs.events | indent 10 }}
  - target:
      kind: ClusterOutput
      group: logging.banzaicloud.io
      version: v1beta1
      name: infra
    patch: |-
      - op: replace
        path: /spec
        value:
{{ $customOutputs.infra | indent 10 }}
  - target:
      kind: Output
      group: logging.banzaicloud.io
      version: v1beta1
      name: ingress-nginx
    patch: |-
      - op: replace
        path: /spec
        value:
{{ $customOutputs.ingressNginx | indent 10 }}
  - target:
      kind: ClusterOutput
      group: logging.banzaicloud.io
      version: v1beta1
      name: kubernetes
    patch: |-
      - op: replace
        path: /spec
        value:
{{ $customOutputs.kubernetes | indent 10 }}
  - target:
      kind: Output
      group: logging.banzaicloud.io
      version: v1beta1
      name: systemd-common
    patch: |-
      - op: replace
        path: /spec
        value:
{{ $customOutputs.systemdCommon | indent 10 }}
  - target:
      kind: Output
      group: logging.banzaicloud.io
      version: v1beta1
      name: systemd-etcd
    patch: |-
      - op: replace
        path: /spec
        value:
{{ $customOutputs.systemdEtcd | indent 10 }}
  - target:
      kind: ClusterOutput
      group: logging.banzaicloud.io
      version: v1beta1
      name: errors
    patch: |-
      - op: replace
        path: /spec
        value:
{{ $customOutputs.errors | indent 10 }}
{{- end }}
{{- if eq .spec.distribution.modules.monitoring.type "none" }}
  - patch: |-
      apiVersion: logging.banzaicloud.io/v1beta1
      kind: Logging
      metadata:
        name: infra
      spec:
        fluentd:
          metrics:
            serviceMonitor: false
            prometheusRules: false
{{- end }}


{{- if eq $loggingType "opensearch" "loki" }}
secretGenerator:
  {{- if eq $loggingType "loki" }}
  - name: loki
    namespace: logging
    behavior: merge
    files:
      - config.yaml=patches/loki-config.yaml
  - name: minio-credentials-loki
    namespace: logging
    behavior: replace
    envs:
      - patches/minio.credentials.loki.env
  {{- end }}
  - name: minio-logging
    namespace: logging
    behavior: replace
    envs:
      - patches/minio.root.env
{{- end }}
