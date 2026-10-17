# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: audit-controller-egress-kube-apiserver
  namespace: gatekeeper-system
  labels:
    cluster.kfd.sighup.io/module: opa
    cluster.kfd.sighup.io/policy-type: gatekeeper  
spec:
  podSelector:
    matchLabels:
      control-plane: audit-controller
  policyTypes:
    - Egress
  egress:
  - ports:
    - port: 6443
      protocol: TCP
