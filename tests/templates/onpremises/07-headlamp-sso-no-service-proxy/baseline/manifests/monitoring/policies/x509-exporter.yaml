# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: x509-exporter-egress-kube-apiserver
  namespace: monitoring
  labels:
    cluster.kfd.sighup.io/module: monitoring
spec:
  policyTypes:
    - Egress
  podSelector:
    matchLabels:
      app: x509-certificate-exporter
  egress:
    - ports:
      - port: 6443
        protocol: TCP
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: x509-exporter-ingress-prometheus-metrics
  namespace: monitoring
  labels:
    cluster.kfd.sighup.io/module: monitoring
spec:
  policyTypes:
    - Ingress
  podSelector:
    matchLabels:
      app: x509-certificate-exporter
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app.kubernetes.io/name: prometheus
    ports:
    - port: 9793
      protocol: TCP
      