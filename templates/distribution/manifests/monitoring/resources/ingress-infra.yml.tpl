# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  labels:
    cluster.kfd.sighup.io/useful-link.enable: "true"
  annotations:
    cluster.kfd.sighup.io/useful-link.url: https://{{ template "alertmanagerUrl" .spec }}
    cluster.kfd.sighup.io/useful-link.name: "Alertmanager"
    forecastle.stakater.com/expose: "true"
    forecastle.stakater.com/appName: "Alertmanager"
    {{ if and (not .spec.distribution.modules.ingress.overrides.ingresses.forecastle.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
    forecastle.stakater.com/group: "monitoring"
    {{ end }}
    forecastle.stakater.com/icon: "https://github.com/stakater/ForecastleIcons/raw/master/alert-manager.png"
    {{ if not .spec.distribution.modules.ingress.overrides.ingresses.forecastle.disableAuth }}{{ template "ingressAuth" . }}{{ end }}
    {{ template "certManagerClusterIssuer" . }}
  name: alertmanager
  {{ if and (not .spec.distribution.modules.monitoring.overrides.ingresses.alertmanager.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
  namespace: pomerium
  {{ else }}
  namespace: monitoring
  {{ end }}
spec:
  ingressClassName: {{ template "ingressClass" (dict "module" "monitoring" "package" "alertmanager" "type" "internal" "spec" .spec) }}
  rules:
    - host: {{ template "alertmanagerUrl" .spec }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
            {{ if and (not .spec.distribution.modules.monitoring.overrides.ingresses.alertmanager.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
              service:
                name: pomerium
                port:
                  number: 80
            {{ else }}
              service:
                name: alertmanager-main
                port:
                  name: web
            {{ end }}
{{- template "ingressTls" (dict "module" "monitoring" "package" "alertmanager" "prefix" "alertmanager." "spec" .spec) }}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  labels:
    cluster.kfd.sighup.io/useful-link.enable: "true"
  annotations:
    cluster.kfd.sighup.io/useful-link.url: https://{{ template "grafanaUrl" .spec }}
    cluster.kfd.sighup.io/useful-link.name: "Grafana"
    forecastle.stakater.com/expose: "true"
    forecastle.stakater.com/appName: "Grafana"
    {{ if and (not .spec.distribution.modules.ingress.overrides.ingresses.forecastle.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
    forecastle.stakater.com/group: "monitoring"
    {{ end }}
    forecastle.stakater.com/icon: "https://github.com/stakater/ForecastleIcons/raw/master/grafana.png"
    {{ if not .spec.distribution.modules.ingress.overrides.ingresses.forecastle.disableAuth }}{{ template "ingressAuth" . }}{{ end }}
    {{ template "certManagerClusterIssuer" . }}
  name: grafana
  {{ if and (not .spec.distribution.modules.monitoring.overrides.ingresses.grafana.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
  namespace: pomerium
  {{ else }}
  namespace: monitoring
  {{ end }}
spec:
  ingressClassName: {{ template "ingressClass" (dict "module" "monitoring" "package" "grafana" "type" "internal" "spec" .spec) }}
  rules:
    - host: {{ template "grafanaUrl" .spec }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
            {{ if and (not .spec.distribution.modules.monitoring.overrides.ingresses.grafana.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
              service:
                name: pomerium
                port:
                  number: 80
            {{ else }}
              service:
                name: grafana
                port:
                  name: http
            {{ end }}
{{- template "ingressTls" (dict "module" "monitoring" "package" "grafana" "prefix" "grafana." "spec" .spec) }}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  labels:
    cluster.kfd.sighup.io/useful-link.enable: "true"
  annotations:
    cluster.kfd.sighup.io/useful-link.url: https://{{ template "prometheusUrl" .spec }}
    cluster.kfd.sighup.io/useful-link.name: "Prometheus"
    forecastle.stakater.com/expose: "true"
    forecastle.stakater.com/appName: "Prometheus"
    {{ if and (not .spec.distribution.modules.ingress.overrides.ingresses.forecastle.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
    forecastle.stakater.com/group: "monitoring"
    {{ end }}
    forecastle.stakater.com/icon: "https://github.com/stakater/ForecastleIcons/raw/master/prometheus.png"
    {{ if not .spec.distribution.modules.ingress.overrides.ingresses.forecastle.disableAuth }}{{ template "ingressAuth" . }}{{ end }}
    {{ template "certManagerClusterIssuer" . }}
  name: prometheus
  {{ if and (not .spec.distribution.modules.monitoring.overrides.ingresses.prometheus.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
  namespace: pomerium
  {{ else }}
  namespace: monitoring
  {{ end }}
spec:
  ingressClassName: {{ template "ingressClass" (dict "module" "monitoring" "package" "prometheus" "type" "internal" "spec" .spec) }}
  rules:
    - host: {{ template "prometheusUrl" .spec }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
            {{ if and (not .spec.distribution.modules.monitoring.overrides.ingresses.prometheus.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
              service:
                name: pomerium
                port:
                  number: 80
            {{ else }}
              service:
                name: prometheus-k8s
                port:
                  name: web
            {{ end }}
{{- template "ingressTls" (dict "module" "monitoring" "package" "prometheus" "prefix" "prometheus." "spec" .spec) }}

{{- if eq .spec.distribution.modules.monitoring.type "mimir" }}
{{- if eq .spec.distribution.modules.monitoring.mimir.backend "minio" }}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  labels:
    cluster.kfd.sighup.io/useful-link.enable: "true"
  annotations:
    cluster.kfd.sighup.io/useful-link.url: https://{{ template "minioMonitoringUrl" .spec }}
    cluster.kfd.sighup.io/useful-link.name: "MinIO Monitoring"
    forecastle.stakater.com/expose: "true"
    forecastle.stakater.com/appName: "MinIO Monitoring"
    {{ if and (not .spec.distribution.modules.ingress.overrides.ingresses.forecastle.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
    forecastle.stakater.com/group: "monitoring"
    {{ end }}
    forecastle.stakater.com/icon: "https://min.io/resources/img/logo/MINIO_Bird.png"
    {{ if not .spec.distribution.modules.monitoring.overrides.ingresses.minio.disableAuth }}{{ template "ingressAuth" . }}{{ end }}
    {{ template "certManagerClusterIssuer" . }}
  {{ if and (not .spec.distribution.modules.monitoring.overrides.ingresses.minio.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
  name: minio-monitoring
  namespace: pomerium
  {{ else }}
  name: minio
  namespace: monitoring
  {{ end }}
spec:
  ingressClassName: {{ template "ingressClass" (dict "module" "monitoring" "package" "minio" "type" "internal" "spec" .spec) }}
  rules:
    - host: {{ template "minioMonitoringUrl" .spec }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
            {{ if and (not .spec.distribution.modules.monitoring.overrides.ingresses.minio.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
              service:
                name: pomerium
                port:
                  number: 80
            {{ else }}
              service:
                name: minio-monitoring-console
                port:
                  name: http
            {{ end }}
{{- template "ingressTls" (dict "module" "monitoring" "package" "minio" "prefix" "minio-monitoring." "spec" .spec) }}
{{- end }}
{{- end }}

{{- if getFieldOrDefault . "spec.distribution.modules.monitoring.grafana.basicAuthIngress" false }}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    {{ template "certManagerClusterIssuer" . }}
  name: grafana-basic-auth
  namespace: monitoring
spec:
  ingressClassName: {{ template "ingressClass" (dict "module" "monitoring" "package" "grafanaBasicAuth" "type" "internal" "spec" .spec) }}
  rules:
    - host: {{ template "grafanaBasicAuthUrl" .spec }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: grafana
                port:
                  name: http
{{- template "ingressTls" (dict "module" "monitoring" "package" "grafanaBasicAuth" "prefix" "grafana-basic-auth." "spec" .spec) }}
{{- end }}
