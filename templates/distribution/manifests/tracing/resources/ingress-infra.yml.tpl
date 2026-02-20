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
    cluster.kfd.sighup.io/useful-link.url: https://{{ template "minioTracingUrl" .spec }}
    cluster.kfd.sighup.io/useful-link.name: "MinIO Tracing"
    forecastle.stakater.com/expose: "true"
    forecastle.stakater.com/appName: "MinIO Tracing"
    {{ if and (not .spec.distribution.modules.ingress.overrides.ingresses.forecastle.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
    forecastle.stakater.com/group: "tracing"
    {{ end }}
    forecastle.stakater.com/icon: "https://min.io/resources/img/logo/MINIO_Bird.png"
    {{ if not .spec.distribution.modules.tracing.overrides.ingresses.minio.disableAuth }}{{ template "ingressAuth" . }}{{ end }}
    {{ template "certManagerClusterIssuer" . }}
    {{ template "byoicAnnotations" . }}
  {{ if and (not .spec.distribution.modules.tracing.overrides.ingresses.minio.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
  name: minio-tracing
  namespace: pomerium
  {{ else }}
  name: minio
  namespace: tracing
  {{ end }}
spec:
  ingressClassName: {{ template "ingressClass" (dict "module" "tracing" "package" "minio" "type" "internal" "spec" .spec) }}
  rules:
    - host: {{ template "minioTracingUrl" .spec }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
            {{ if and (not .spec.distribution.modules.tracing.overrides.ingresses.minio.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
              service:
                name: pomerium
                port:
                  number: 80
            {{ else }}
              service:
                name: minio-tracing-console
                port:
                  name: http
            {{ end }}
{{- template "ingressTls" (dict "module" "tracing" "package" "minio" "prefix" "minio-tracing." "spec" .spec) }}
