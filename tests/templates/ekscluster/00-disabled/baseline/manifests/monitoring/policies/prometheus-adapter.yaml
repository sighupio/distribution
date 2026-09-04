# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# source: https://github.com/prometheus-operator/kube-prometheus/blob/main/manifests/prometheusAdapter-networkPolicy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: prometheus-adapter
  namespace: monitoring
  labels:
    cluster.kfd.sighup.io/module: monitoring
spec:
  egress:
  - {}
  ingress:
  - {}
  podSelector:
    matchLabels:
      app.kubernetes.io/component: metrics-adapter
      app.kubernetes.io/name: prometheus-adapter
      app.kubernetes.io/part-of: kube-prometheus
  policyTypes:
  - Egress
  - Ingress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: prometheus-ingress-prometheus-adapter
  namespace: monitoring
  labels:
    cluster.kfd.sighup.io/module: monitoring
spec:
  policyTypes:
    - Ingress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: prometheus
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app.kubernetes.io/component: metrics-adapter
              app.kubernetes.io/name: prometheus-adapter
              app.kubernetes.io/part-of: kube-prometheus
      ports:
        - port: 9090
          protocol: TCP
---
