# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: loki-distributed-ingress-fluentd
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
    cluster.kfd.sighup.io/logging-type: loki
spec:
  policyTypes:
    - Ingress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: loki-distributed
      app.kubernetes.io/component: gateway
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: logging
          podSelector:
            matchLabels:
              app.kubernetes.io/name: fluentd
      ports:
        - port: 8080
          protocol: TCP
        - port: 3100
          protocol: TCP
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: loki-distributed-ingress-grafana
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
    cluster.kfd.sighup.io/logging-type: loki
spec:
  policyTypes:
    - Ingress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: loki-distributed
      app.kubernetes.io/component: gateway
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: monitoring
          podSelector:
            matchLabels:
              app.kubernetes.io/name: grafana
      ports:
        - port: 8080
          protocol: TCP
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: loki-distributed-ingress-prometheus-metrics
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
    cluster.kfd.sighup.io/logging-type: loki
spec:
  policyTypes:
    - Ingress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: loki-distributed
  ingress:
    - ports:
        - port: 3100
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
  name: loki-distributed-discovery
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
    cluster.kfd.sighup.io/logging-type: loki
spec:
  policyTypes:
    - Ingress
    - Egress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: loki-distributed
  ingress:
    - ports:
        - port: 9095
          protocol: TCP
        - port: 3100
          protocol: TCP
        - port: 7946
          protocol: TCP
      from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: logging
          podSelector:
            matchLabels:
              app.kubernetes.io/name: loki-distributed
  egress:
    - ports:
        - port: 9095
          protocol: TCP
        - port: 3100
          protocol: TCP
        - port: 7946
          protocol: TCP
      to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: logging
          podSelector:
            matchLabels:
              app.kubernetes.io/name: loki-distributed
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: loki-distributed-egress-all
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
    cluster.kfd.sighup.io/logging-type: loki
spec:
  policyTypes:
    - Egress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: loki-distributed
  egress:
    - {}
---
{{- if and (eq .spec.distribution.common.provider.type "none" "immutable") (hasKeyAny .spec "kubernetes") (has (.spec | digAny "distribution" "modules" "utilities" "headlamp" "type" "none") (list "token-auth" "sso")) }}
# The kube-apiserver runs in the host network, so its service proxy requests
# (for example Headlamp's logs and events) come from node addresses, not from pods.
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: loki-distributed-gateway-ingress-kube-apiserver
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
    cluster.kfd.sighup.io/logging-type: loki
spec:
  policyTypes:
    - Ingress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: loki-distributed
      app.kubernetes.io/component: gateway
  ingress:
    - ports:
        - port: 8080
          protocol: TCP
---
{{- end }}
