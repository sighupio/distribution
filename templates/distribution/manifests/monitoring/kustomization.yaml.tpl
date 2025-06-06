# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $monitoringType := .spec.distribution.modules.monitoring.type }}
{{- $installEnhancedHPAMetrics := .spec.distribution.modules.monitoring.prometheusAdapter.installEnhancedHPAMetrics }}
# rendering Kustomization file for monitoring type {{ $monitoringType }}

---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
{{- /* common components for all the monitoring types */}}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/prometheus-operator" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/kube-proxy-metrics" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/kube-state-metrics" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/node-exporter" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/x509-exporter" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/blackbox-exporter" }}
{{- if eq .spec.distribution.common.provider.type "none" }}{{/* none === on-premises and kfddistribution */}}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/kubeadm-sm" }}
  {{- if hasKeyAny .spec "kubernetes" }}
    {{- if .spec.kubernetes.loadBalancers.enabled }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/haproxy" }}
  - resources/haproxy-scrapeConfig.yaml
    {{- end }}
  {{- end }}
{{- end }}
{{- if eq .spec.distribution.common.provider.type "eks" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/eks-sm" }}
{{- end }}
{{- if or (eq $monitoringType "prometheus") (eq $monitoringType "mimir") }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/alertmanager-operated" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/prometheus-adapter" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/grafana" }}
    {{- if .checks.storageClassAvailable }}
        {{- if eq $monitoringType "prometheus" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/prometheus-operated" }}
        {{- else if eq $monitoringType "mimir" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/mimir" }}
            {{- if eq .spec.distribution.modules.monitoring.mimir.backend "minio" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/monitoring/katalog/minio-ha" }}
            {{- end }}
        {{- end }}
    {{- end }}
    {{- if and (ne .spec.distribution.modules.ingress.nginx.type "none") }}{{/* we don't need ingresses for Prometheus in Agent mode */}}
  - resources/ingress-infra.yml
    {{- end }}
{{- end }}
{{- if eq $monitoringType "prometheusAgent" }}
  - ./resources/prometheus-agent/
{{- end }}
{{- if or .spec.distribution.modules.monitoring.alertmanager.deadManSwitchWebhookUrl .spec.distribution.modules.monitoring.alertmanager.slackWebhookUrl }}
  - secrets/alertmanager.yml
{{- end }}

{{ if eq .spec.distribution.common.networkPoliciesEnabled true }}
  - policies
{{- end }}

patchesStrategicMerge:
  - patches/infra-nodes.yml
{{- if eq .spec.distribution.common.provider.type "eks" }}{{/* in EKS there are no files to monitor on nodes */}}
  - |-
    $patch: delete
    apiVersion: apps/v1
    kind: DaemonSet
    metadata:
      namespace: monitoring
      name: x509-certificate-exporter-data-plane
{{- end }}
{{- if or (eq $monitoringType "prometheus") (eq $monitoringType "mimir") }}
  - patches/alertmanager-operated.yml
  {{- if .checks.storageClassAvailable }}
  {{- /* notice that prometheus-operated is (also) installed as a dependency of mimir in its kustomize base */}}
  - patches/prometheus-operated.yml
    {{- if and (eq $monitoringType "mimir") (eq .spec.distribution.modules.monitoring.mimir.backend "minio") }}
  - patches/minio.yml
    {{- end }}
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
{{- if or (eq $monitoringType "prometheus") (eq $monitoringType "mimir") }}
  {{- if not $installEnhancedHPAMetrics }}
  - |-
    $patch: delete
    apiVersion: apiregistration.k8s.io/v1
    kind: APIService
    metadata:
      name: v1beta1.custom.metrics.k8s.io
  - |-
    $patch: delete
    apiVersion: apiregistration.k8s.io/v1
    kind: APIService
    metadata:
      name: v1beta1.external.metrics.k8s.io
  {{- end }}
{{- end }}

configMapGenerator:
{{- if .checks.storageClassAvailable }}
  {{- if eq $monitoringType "mimir" }}
  - name: mimir-distributed-config
    namespace: monitoring
    behavior: replace
    files:
      - patches/mimir.yaml
  {{- end }}
{{- end }}
{{- if or (eq $monitoringType "prometheus") (eq $monitoringType "mimir") }}
  {{- if not $installEnhancedHPAMetrics }}
  - name: adapter-config
    namespace: monitoring
    behavior: replace
    files:
      - config.yaml=patches/adapter-config.yml
  {{- end }}
{{- end }}

secretGenerator:
{{- if .checks.storageClassAvailable }}
  {{- if and (eq .spec.distribution.modules.monitoring.type "mimir") (eq .spec.distribution.modules.monitoring.mimir.backend "minio") }}
  - name: minio-monitoring
    namespace: monitoring
    behavior: replace
    envs:
      - patches/minio.root.env
  {{- end }}
{{- end }}
{{- if or (eq $monitoringType "prometheus") (eq $monitoringType "mimir") }}
  {{- if eq .spec.distribution.modules.auth.provider.type "sso" }}
  - name: grafana-config
    behavior: merge
    namespace: monitoring
    files:
      - grafana.ini=patches/grafana.ini
  {{- end }}
{{- end }}
