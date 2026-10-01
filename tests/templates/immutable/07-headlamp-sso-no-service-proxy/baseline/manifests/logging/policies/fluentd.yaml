# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: fluentd-egress-all
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
    cluster.kfd.sighup.io/logging-backend: minio
spec:
  policyTypes:
    - Egress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: fluentd
  egress:
    - {}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: fluentd-ingress-fluentbit
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
spec:
  policyTypes:
    - Ingress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: fluentd
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app.kubernetes.io/name: fluentbit
          namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: logging
      ports:
          - port: 24240
            protocol: TCP
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: fluentd-ingress-prometheus-metrics
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
spec:
  policyTypes:
    - Ingress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: fluentd
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app.kubernetes.io/name: prometheus
          namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: monitoring
      ports:
          - port: 24231
            protocol: TCP
---

