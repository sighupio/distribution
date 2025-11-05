# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: opensearch-ingress-dashboards
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
    cluster.kfd.sighup.io/logging-type: opensearch
spec:
  policyTypes:
    - Ingress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: opensearch
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: logging
          podSelector:
            matchLabels:
              app.kubernetes.io/name: opensearch-dashboards
      ports:
        - port: 9200
          protocol: TCP
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: opensearch-ingress-fluentd
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
    cluster.kfd.sighup.io/logging-type: opensearch
spec:
  policyTypes:
    - Ingress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: opensearch
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: logging
          podSelector:
            matchLabels:
              app.kubernetes.io/name: fluentd
      ports:
        - port: 9200
          protocol: TCP
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: opensearch-discovery
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
    cluster.kfd.sighup.io/logging-type: opensearch
spec:
  policyTypes:
    - Ingress
    - Egress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: opensearch
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: logging
          podSelector:
            matchLabels:
              app.kubernetes.io/name: opensearch
      ports:
        - port: 9300
          protocol: TCP
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: logging
          podSelector:
            matchLabels:
              app.kubernetes.io/name: opensearch
      ports:
        - port: 9300
          protocol: TCP
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: opensearch-ingress-prometheus-metrics
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
    cluster.kfd.sighup.io/logging-type: opensearch
spec:
  policyTypes:
    - Ingress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: opensearch
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: monitoring
          podSelector:
            matchLabels:
              app.kubernetes.io/name: prometheus
      ports:
        - port: 9108
          protocol: TCP
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: opensearch-ingress-jobs
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
    cluster.kfd.sighup.io/logging-type: opensearch
spec:
  policyTypes:
    - Ingress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: opensearch
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app.kubernetes.io/name: opensearch
              app.kubernetes.io/instance: opensearch
      ports:
        - port: 9200
          protocol: TCP
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: jobs-egress-opensearch
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
    cluster.kfd.sighup.io/logging-type: opensearch
spec:
  policyTypes:
    - Egress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: opensearch
      app.kubernetes.io/instance: opensearch
  egress:
    - to:
        - podSelector:
            matchLabels:
              app.kubernetes.io/name: opensearch
      ports:
        - port: 9200
          protocol: TCP
---