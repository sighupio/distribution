# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: haproxy-egress-all
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
    - Egress
  egress:
    - {}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: all-ingress-haproxy
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
    - ports:
        - port: 6060
          protocol: TCP
        - port: 8080
          protocol: TCP
        - port: 8443
          protocol: TCP
        - port: 1024
          protocol: TCP
