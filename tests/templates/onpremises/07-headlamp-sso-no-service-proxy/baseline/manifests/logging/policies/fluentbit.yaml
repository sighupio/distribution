# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: fluentbit-egress-fluentd
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
spec:
  policyTypes:
    - Egress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: fluentbit
  egress:
    - ports:
      # fluentd
      - port: 24240
        protocol: TCP
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: fluentbit-egress-kube-apiserver
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
spec:
  policyTypes:
    - Egress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: fluentbit
  egress:
    - ports:
      - port: 6443
        protocol: TCP
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: fluentbit-ingress-prometheus-metrics
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
spec:
  policyTypes:
    - Ingress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: fluentbit
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app.kubernetes.io/name: prometheus
          namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: monitoring
      ports:
          - port: 2020
            protocol: TCP
