# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

{{- $vendorPrefix := print "../" .spec.distribution.common.relativeVendorPath }}
{{- $loggingType := .spec.distribution.modules.logging.type }}
{{- $customOutputs := .spec.distribution.modules.logging.customOutputs }}
{{- $loki := index .spec.distribution.modules.logging "loki" }}
{{- $fluentdReplicas := index .spec.distribution.modules.logging.operator.fluentd "replicas" }}
{{- $fluentdResources := index .spec.distribution.modules.logging.operator.fluentd "resources" }}
{{- $fluentbitResources := index .spec.distribution.modules.logging.operator.fluentbit "resources" }}
{{- $haproxyType := .spec.distribution.modules.ingress.haproxy.type }}
{{- $isBYOIC := .spec.distribution.modules.ingress.byoic.enabled }}
{{- $hasAnyIngress := or (ne .spec.distribution.modules.ingress.nginx.type "none") (ne $haproxyType "none") $isBYOIC }}

resources:
  - {{ print $vendorPrefix "/modules/logging/katalog/logging-operator" }}
  - {{ print $vendorPrefix "/modules/logging/katalog/logging-operated" }}
  - kapp-configs/logging-operator-crd.yaml
{{- if eq $loggingType "loki" "opensearch" }}
  - {{ print $vendorPrefix "/modules/logging/katalog/minio-ha" }}
  {{- if $hasAnyIngress }}
  - resources/ingress-infra.yml
  {{- end }}
{{- end }}
{{- if eq $loggingType "opensearch" "customOutputs" }}
  - {{ print $vendorPrefix "/modules/logging/katalog/configs/audit" }}
  - {{ print $vendorPrefix "/modules/logging/katalog/configs/events" }}
  - {{ print $vendorPrefix "/modules/logging/katalog/configs/infra" }}
  {{- if ne $haproxyType "none" }}
  - {{ print $vendorPrefix "/modules/logging/katalog/configs/ingress-haproxy" }}
  {{- end }}
  {{- if ne .spec.distribution.modules.ingress.nginx.type "none" }}
  - {{ print $vendorPrefix "/modules/logging/katalog/configs/ingress-nginx" }}
  {{- end }}
  - {{ print $vendorPrefix "/modules/logging/katalog/configs/kubernetes" }}
  - {{ print $vendorPrefix "/modules/logging/katalog/configs/systemd" }}
  {{- if eq $loggingType "opensearch" }}
  - {{ print $vendorPrefix "/modules/logging/katalog/opensearch-dashboards" }}
    {{- if eq .spec.distribution.modules.logging.opensearch.type "single" }}
  - {{ print $vendorPrefix "/modules/logging/katalog/opensearch-single" }}
    {{- else if eq .spec.distribution.modules.logging.opensearch.type "triple" }}
  - {{ print $vendorPrefix "/modules/logging/katalog/opensearch-triple" }}
    {{- end }}
  {{- end }}
{{- else if eq $loggingType "loki" }}
  - {{ print $vendorPrefix "/modules/logging/katalog/loki-configs/audit" }}
  - {{ print $vendorPrefix "/modules/logging/katalog/loki-configs/events" }}
  - {{ print $vendorPrefix "/modules/logging/katalog/loki-configs/infra" }}
  {{- if ne $haproxyType "none" }}
  - {{ print $vendorPrefix "/modules/logging/katalog/loki-configs/ingress-haproxy" }}
  {{- end }}
  {{- if ne .spec.distribution.modules.ingress.nginx.type "none" }}
  - {{ print $vendorPrefix "/modules/logging/katalog/loki-configs/ingress-nginx" }}
  {{- end }}
  - {{ print $vendorPrefix "/modules/logging/katalog/loki-configs/kubernetes" }}
  - {{ print $vendorPrefix "/modules/logging/katalog/loki-configs/systemd" }}
  - {{ print $vendorPrefix "/modules/logging/katalog/loki-distributed" }}
  - kapp-configs/loki-hpa.yaml
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
      kind: Output
      group: logging.banzaicloud.io
      version: v1beta1
      name: ingress-haproxy
    patch: |-
      - op: replace
        path: /spec
        value:
{{ $customOutputs.ingressHaproxy | indent 10 }}
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
