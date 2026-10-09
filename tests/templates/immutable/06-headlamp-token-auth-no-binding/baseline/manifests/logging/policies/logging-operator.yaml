# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: logging-operator-egress-kube-apiserver
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
spec:
  policyTypes:
    - Egress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: logging-operator
  egress:
  - ports:
    - port: 6443
      protocol: TCP
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: logging-operator-ingress-prometheus-metrics
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
spec:
  policyTypes:
    - Ingress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: logging-operator
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app.kubernetes.io/name: prometheus
          namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: monitoring
      ports:
        - port: 8080
          protocol: TCP
