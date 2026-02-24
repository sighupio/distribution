# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: minio-ingress-namespace
  namespace: tracing
  labels:
    cluster.kfd.sighup.io/module: tracing
    cluster.kfd.sighup.io/tracing-backend: minio
spec:
  policyTypes:
    - Ingress
    - Egress
  podSelector:
    matchLabels:
      app: minio
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: tracing
      ports:
      - port: 9000
        protocol: TCP
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: tracing
          podSelector:
            matchLabels:
              app: minio
      ports:
      - port: 9000
        protocol: TCP
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: minio-buckets-setup-egress-kube-apiserver
  namespace: tracing
  labels:
    cluster.kfd.sighup.io/module: tracing
    cluster.kfd.sighup.io/tracing-backend: minio
spec:
  policyTypes:
    - Egress
  podSelector:
    matchLabels:
      app: minio-tracing-buckets-setup
  egress:
    - ports:
      - port: 6443
        protocol: TCP
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: minio-buckets-setup-egress-minio
  namespace: tracing
  labels:
    cluster.kfd.sighup.io/module: tracing
    cluster.kfd.sighup.io/tracing-backend: minio
spec:
  policyTypes:
    - Egress
  podSelector:
    matchLabels:
      app: minio-tracing-buckets-setup
  egress:
    - ports:
      - port: 9000
        protocol: TCP
      to:
      - podSelector:
            matchLabels:
              app: minio
        namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: tracing
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: minio-ingress-prometheus-metrics
  namespace: tracing
  labels:
    cluster.kfd.sighup.io/module: tracing
    cluster.kfd.sighup.io/tracing-backend: minio
spec:
  policyTypes:
    - Ingress
  podSelector:
    matchLabels:
      app: minio
  ingress:
    - ports:
        - port: 9000
          protocol: TCP
      from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: monitoring
          podSelector:
            matchLabels:
              app.kubernetes.io/name: prometheus
{{- $nginxType := .spec.distribution.modules.ingress.nginx.type }}
{{- $haproxyType := .spec.distribution.modules.ingress.haproxy.type }}
{{- $isSSO := eq .spec.distribution.modules.auth.provider.type "sso" }}
{{- $isBYOIC := .spec.distribution.modules.ingress.byoic.enabled }}

{{- if $isSSO }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: minio-ingress-pomerium
  namespace: tracing
  labels:
    cluster.kfd.sighup.io/module: tracing
    cluster.kfd.sighup.io/tracing-backend: minio
spec:
  policyTypes:
    - Ingress
  podSelector:
    matchLabels:
      app: minio
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: pomerium
          podSelector:
            matchLabels:
              app: pomerium
      ports:
        - port: 9001
          protocol: TCP
{{- else }}
  {{- if ne $nginxType "none" }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: minio-ingress-nginx
  namespace: tracing
  labels:
    cluster.kfd.sighup.io/module: tracing
    cluster.kfd.sighup.io/tracing-backend: minio
spec:
  policyTypes:
    - Ingress
  podSelector:
    matchLabels:
      app: minio
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: ingress-nginx
          podSelector:
            matchLabels:
    {{- if eq $nginxType "dual" }}
              app: ingress
    {{- else }}
              app: ingress-nginx
    {{- end }}
      ports:
        - port: 9001
          protocol: TCP
  {{- end }}
  {{- if ne $haproxyType "none" }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: minio-ingress-haproxy
  namespace: tracing
  labels:
    cluster.kfd.sighup.io/module: tracing
    cluster.kfd.sighup.io/tracing-backend: minio
spec:
  policyTypes:
    - Ingress
  podSelector:
    matchLabels:
      app: minio
  ingress:
    - from:
      - namespaceSelector:
          matchLabels:
            kubernetes.io/metadata.name: ingress-haproxy
        podSelector:
          matchLabels:
            app.kubernetes.io/name: kubernetes-ingress
            app.kubernetes.io/instance: haproxy-ingress
      ports:
        - port: 9001
          protocol: TCP
  {{- end }}
  {{- if $isBYOIC }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: minio-ingress-byoic
  namespace: tracing
  labels:
    cluster.kfd.sighup.io/module: tracing
    cluster.kfd.sighup.io/tracing-backend: minio
spec:
  policyTypes:
    - Ingress
  podSelector:
    matchLabels:
      app: minio
  ingress:
    - ports:
        - port: 9001
          protocol: TCP
  {{- end }}
{{- end }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: minio-egress-https
  namespace: tracing
  labels:
    cluster.kfd.sighup.io/module: tracing
    cluster.kfd.sighup.io/tracing-backend: minio
spec:
  policyTypes:
    - Egress
  podSelector:
    matchLabels:
      app: minio
  egress:
    - ports:
      - port: 443
        protocol: TCP
---