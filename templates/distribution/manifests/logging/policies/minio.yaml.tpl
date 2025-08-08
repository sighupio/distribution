# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: minio-ingress-namespace
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
    cluster.kfd.sighup.io/logging-backend: minio
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
              kubernetes.io/metadata.name: logging
      ports:
      - port: 9000
        protocol: TCP
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: logging
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
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
    cluster.kfd.sighup.io/logging-backend: minio
spec:
  policyTypes:
    - Egress
  podSelector:
    matchLabels:
      app: minio-logging-buckets-setup
  egress:
    - ports:
      - port: 6443
        protocol: TCP
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: minio-buckets-setup-egress-minio
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
    cluster.kfd.sighup.io/logging-backend: minio
spec:
  policyTypes:
    - Egress
  podSelector:
    matchLabels:
      app: minio-logging-buckets-setup
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
              kubernetes.io/metadata.name: logging

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: minio-ingress-prometheus-metrics
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
    cluster.kfd.sighup.io/logging-backend: minio
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
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: minio-egress-https
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
    cluster.kfd.sighup.io/logging-backend: minio
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
{{- if ne .spec.distribution.modules.ingress.nginx.type "none" }}
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: minio-ingress-nginx
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
    cluster.kfd.sighup.io/logging-backend: minio
spec:
  policyTypes:
    - Ingress
  podSelector:
    matchLabels:
      app: minio
  ingress:
# single nginx, no sso
{{ if and (eq .spec.distribution.modules.ingress.nginx.type "single") (ne .spec.distribution.modules.auth.provider.type "sso") }}
    - from:
      - namespaceSelector:
          matchLabels:
            kubernetes.io/metadata.name: ingress-nginx
        podSelector:
          matchLabels:
            app: ingress-nginx
# dual nginx, no sso
{{ else if and (eq .spec.distribution.modules.ingress.nginx.type "dual") (ne .spec.distribution.modules.auth.provider.type "sso") }}
    - from:
      - namespaceSelector:
          matchLabels:
            kubernetes.io/metadata.name: ingress-nginx
        podSelector:
          matchLabels:
            app: ingress
# sso
{{ else if (eq .spec.distribution.modules.auth.provider.type "sso") }}
    - from:
      - namespaceSelector:
          matchLabels:
            kubernetes.io/metadata.name: pomerium
        podSelector:
          matchLabels:
            app: pomerium
{{ end }}
      ports:
        - port: 9001
          protocol: TCP
{{- end }}
---
