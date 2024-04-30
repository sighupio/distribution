# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/alertmanager-operated" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/blackbox-exporter" }}
{{- if eq .spec.distribution.common.provider.type "none" }}{{/* none === on-premises */}}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/kubeadm-sm" }}
{{- end }}
{{- if eq .spec.distribution.common.provider.type "eks" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/eks-sm" }}
{{- end }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/grafana" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/kube-proxy-metrics" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/kube-state-metrics" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/node-exporter" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/prometheus-adapter" }}
{{- if .checks.storageClassAvailable }}
  {{- if eq .spec.distribution.modules.monitoring.type "prometheus" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/prometheus-operated" }}
  {{- end }}
  {{- if eq .spec.distribution.modules.monitoring.type "mimir" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/mimir" }}
    {{- if eq .spec.distribution.modules.monitoring.mimir.backend "minio" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/minio-ha" }}
    {{- end }}
  {{- end }}
{{- end }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/prometheus-operator" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/x509-exporter" }}
{{- if ne .spec.distribution.modules.ingress.nginx.type "none" }}
  - resources/ingress-infra.yml
{{- end }}
{{- if or .spec.distribution.modules.monitoring.alertmanager.deadManSwitchWebhookUrl .spec.distribution.modules.monitoring.alertmanager.slackWebhookUrl }}
  - secrets/alertmanager.yml
{{- end }}

patchesStrategicMerge:
  - patches/alertmanager-operated.yml
  - patches/infra-nodes.yml
{{- if .checks.storageClassAvailable }}
  - patches/prometheus-operated.yml
  {{- if and (eq .spec.distribution.modules.monitoring.type "mimir") (eq .spec.distribution.modules.monitoring.mimir.backend "minio") }}
  - patches/minio.yml
  {{- end }}
{{- end }}
{{- if not .spec.distribution.modules.monitoring.alertmanager.installDefaultRules }}
{{- if .spec.distribution.modules.monitoring.alertmanager.deadManSwitchWebhookUrl }}
  - |-
    $patch: delete
    apiVersion: v1
    kind: Secret
    metadata:
      namespace: monitoring
      name: healthchecks-webhook
{{- end }}
{{- if .spec.distribution.modules.monitoring.alertmanager.slackWebhookUrl }}
  - |-
    $patch: delete
    apiVersion: v1
    kind: Secret
    metadata:
      namespace: monitoring
      name: infra-slack-webhook
  - |-
    $patch: delete
    apiVersion: v1
    kind: Secret
    metadata:
      namespace: monitoring
      name: k8s-slack-webhook
{{- end }}
{{- end }}

{{- if .checks.storageClassAvailable }}
  {{- if eq .spec.distribution.modules.monitoring.type "mimir" }}
configMapGenerator:
  - name: mimir-distributed-config
    namespace: monitoring
    behavior: replace
    files:
      - patches/mimir.yaml

    {{- if eq .spec.distribution.modules.monitoring.mimir.backend "minio" }}

secretGenerator:
  - name: minio-monitoring
    namespace: monitoring
    behavior: replace
    envs:
      - patches/minio.root.env
    {{- end }}
  {{- end }}
{{- end }}
