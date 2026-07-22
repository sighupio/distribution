# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: pomerium-ingress-prometheus-metrics
  namespace: pomerium
  labels:
    cluster.kfd.sighup.io/module: auth
    cluster.kfd.sighup.io/auth-provider-type: sso
spec:
  podSelector:
    matchLabels:
      app: pomerium
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
          port: 9090
---
