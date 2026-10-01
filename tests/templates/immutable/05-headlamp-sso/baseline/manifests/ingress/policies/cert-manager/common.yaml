# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
  namespace: cert-manager
  labels:
    cluster.kfd.sighup.io/module: ingress
    cluster.kfd.sighup.io/ingress-type: nginx
spec:
  podSelector: {}
  policyTypes:
    - Egress
    - Ingress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: all-egress-kube-dns
  namespace: cert-manager
  labels:
    cluster.kfd.sighup.io/module: ingress
    cluster.kfd.sighup.io/ingress-type: nginx
spec:
  podSelector:
    matchLabels: {}
  policyTypes:
    - Egress
  egress:
    - ports:
        - protocol: UDP
          port: 53
        - protocol: TCP
          port: 53
          # https://cert-manager.io/docs/installation/best-practice/#network-requirements