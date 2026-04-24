# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $monitoringType := .spec.distribution.modules.monitoring.type }}

# source: https://github.com/prometheus-operator/kube-prometheus/blob/main/manifests/prometheus-networkPolicy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: prometheus-k8s
  namespace: monitoring
spec:
  egress:
  - {}
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app.kubernetes.io/name: prometheus
    ports:
    - port: 9090
      protocol: TCP
    - port: 8080
      protocol: TCP
  - from:
    - podSelector:
        matchLabels:
          app.kubernetes.io/name: prometheus-adapter
    ports:
    - port: 9090
      protocol: TCP
  - from:
    - podSelector:
        matchLabels:
          app.kubernetes.io/name: grafana
    ports:
    - port: 9090
      protocol: TCP
  podSelector:
    matchLabels:
      app.kubernetes.io/component: prometheus
      app.kubernetes.io/instance: k8s
      app.kubernetes.io/name: prometheus
      app.kubernetes.io/part-of: kube-prometheus
  policyTypes:
  - Egress
  - Ingress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: prometheus-egress-minio
  namespace: monitoring
spec:
  policyTypes:
    - Egress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: prometheus
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: minio
      ports:
        - port: 9000
          protocol: TCP
---
{{- if eq $monitoringType "mimir" }}
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: prometheus-egress-mimir
  namespace: monitoring
spec:
  policyTypes:
    - Egress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: prometheus
      app.kubernetes.io/instance: k8s
  egress:
    - to:
        - podSelector:
            matchLabels:
              app.kubernetes.io/component: gateway
              app.kubernetes.io/name: mimir
              app.kubernetes.io/instance: mimir-distributed
      ports:
        - port: 8080
          protocol: TCP
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: prometheus-egress-kube-apiserver
  namespace: monitoring
spec:
  policyTypes:
    - Egress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: prometheus
  egress:
    - ports:
        - port: 6443
          protocol: TCP
        - port: 8405
          protocol: TCP
---
{{- if .spec | digAny "kubernetes" "etcd" nil }}
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: prometheus-egress-external-etcd
  namespace: monitoring
spec:
  policyTypes:
    - Egress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: prometheus
  egress:
    - ports:
        - port: 2378
          protocol: TCP
---
{{- end }}
{{- if eq .spec.distribution.modules.monitoring.mimir.backend "minio" }}
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: prometheus-egress-miniologging
  namespace: monitoring
  labels:
    cluster.kfd.sighup.io/module: monitoring
spec:
  policyTypes:
    - Egress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: prometheus
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
  name: prometheus-egress-minio-monitoring
  namespace: monitoring
  labels:
    cluster.kfd.sighup.io/module: monitoring
spec:
  policyTypes:
    - Egress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: prometheus
      app.kubernetes.io/instance: k8s
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: monitoring
          podSelector:
            matchLabels:
              app: minio
      ports:
        - port: 9000
          protocol: TCP
---
{{- end }}
{{- end }}

