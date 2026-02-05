# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: haproxy-ingress-prometheus-metrics
  namespace: ingress-haproxy
  labels:
    cluster.kfd.sighup.io/module: ingress
    cluster.kfd.sighup.io/ingress-type: haproxy
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: kubernetes-ingress
      app.kubernetes.io/instance: haproxy-ingress
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: monitoring
          podSelector:
            matchLabels:
              app.kubernetes.io/name: prometheus
      ports:
        - protocol: TCP
          port: 10254
