# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- if eq .spec.distribution.modules.logging.type "opensearch" }}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  labels:
    cluster.kfd.sighup.io/useful-link.enable: "true"
  annotations:
    cluster.kfd.sighup.io/useful-link.url: https://{{ template "opensearchDashboardsUrl" .spec }}
    cluster.kfd.sighup.io/useful-link.name: "Opensearch Dashboards"
    forecastle.stakater.com/expose: "true"
    forecastle.stakater.com/appName: "Opensearch Dashboards"
    {{ if and (not .spec.distribution.modules.ingress.overrides.ingresses.forecastle.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
    forecastle.stakater.com/group: "logging"
    {{ end }}
    forecastle.stakater.com/icon: "https://opensearch.org/assets/brand/PNG/Mark/opensearch_mark_default.png"
    {{ if not .spec.distribution.modules.logging.overrides.ingresses.opensearchDashboards.disableAuth }}{{ template "ingressAuth" . }}{{ end }}
    {{ template "certManagerClusterIssuer" . }}
    {{ template "byoicAnnotations" . }}
  name: opensearch-dashboards
  {{ if and (not .spec.distribution.modules.logging.overrides.ingresses.opensearchDashboards.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
  namespace: pomerium
  {{ else }}
  namespace: logging
  {{ end }}
spec:
  ingressClassName: {{ template "ingressClass" (dict "module" "logging" "package" "opensearchDashboards" "type" "internal" "spec" .spec) }}
  rules:
    - host: {{ template "opensearchDashboardsUrl" .spec }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
            {{ if and (not .spec.distribution.modules.logging.overrides.ingresses.opensearchDashboards.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
              service:
                name: pomerium
                port:
                  number: 80
            {{ else }}
              service:
                name: opensearch-dashboards
                port:
                  name: http
            {{ end }}
{{- template "ingressTls" (dict "module" "logging" "package" "opensearchDashboards" "prefix" "opensearch-dashboards." "spec" .spec) }}
{{- end }}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  labels:
    cluster.kfd.sighup.io/useful-link.enable: "true"
  annotations:
    cluster.kfd.sighup.io/useful-link.url: https://{{ template "minioLoggingUrl" .spec }}
    cluster.kfd.sighup.io/useful-link.name: "MinIO Logging"
    forecastle.stakater.com/expose: "true"
    forecastle.stakater.com/appName: "MinIO Logging"
    {{ if and (not .spec.distribution.modules.ingress.overrides.ingresses.forecastle.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
    forecastle.stakater.com/group: "logging"
    {{ end }}
    forecastle.stakater.com/icon: "https://min.io/resources/img/logo/MINIO_Bird.png"
    {{ if not .spec.distribution.modules.logging.overrides.ingresses.minio.disableAuth }}{{ template "ingressAuth" . }}{{ end }}
    {{ template "certManagerClusterIssuer" . }}
    {{ template "byoicAnnotations" . }}

  {{ if and (not .spec.distribution.modules.logging.overrides.ingresses.minio.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
  name: minio-logging
  namespace: pomerium
  {{ else }}
  name: minio
  namespace: logging
  {{ end }}
spec:
  ingressClassName: {{ template "ingressClass" (dict "module" "logging" "package" "minio" "type" "internal" "spec" .spec) }}
  rules:
    - host: {{ template "minioLoggingUrl" .spec }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
            {{ if and (not .spec.distribution.modules.logging.overrides.ingresses.minio.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
              service:
                name: pomerium
                port:
                  number: 80
            {{ else }}
              service:
                name: minio-logging-console
                port:
                  name: http
            {{ end }}
{{- template "ingressTls" (dict "module" "logging" "package" "minio" "prefix" "minio-logging." "spec" .spec) }}
