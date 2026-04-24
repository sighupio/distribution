# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $monitoringType := .spec.distribution.modules.monitoring.type }}
{{- $haproxyType := .spec.distribution.modules.ingress.haproxy.type }}
{{- $isBYOIC := .spec.distribution.modules.ingress.byoic.enabled }}
{{- $hasAnyIngress := or (ne .spec.distribution.modules.ingress.nginx.type "none") (ne $haproxyType "none") $isBYOIC }}
---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - common.yaml
  - prometheus-operator.yaml
  - kube-state-metrics.yaml
  - node-exporter.yaml
  - x509-exporter.yaml
  - blackbox-exporter.yaml

{{- if or (eq $monitoringType "prometheus") (eq $monitoringType "mimir") }}
  - alertmanager.yaml
  - prometheus-adapter.yaml
  - grafana.yaml
  - prometheus.yaml
{{- end }}
{{- if eq $monitoringType "mimir" }}
  - mimir.yaml
{{- if eq .spec.distribution.modules.monitoring.mimir.backend "minio" }}
  - minio.yaml
{{- end }}  
{{- end }}

{{- if $hasAnyIngress }}{{/* we don't need ingresses for Prometheus in Agent mode */}}
  - ingress.yaml
{{- end }}
