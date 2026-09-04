# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: gpm-egress-kube-apiserver
  namespace: gatekeeper-system
  labels:
    cluster.kfd.sighup.io/module: opa
    cluster.kfd.sighup.io/policy-type: gatekeeper
spec:
  podSelector:
    matchLabels:
      app: gatekeeper-policy-manager
  policyTypes:
    - Egress
  egress:
  - ports:
    - port: 6443
      protocol: TCP
---
{{- if eq .spec.distribution.modules.auth.provider.type "sso" }}
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: gpm-ingress-pomerium
  namespace: gatekeeper-system
  labels:
    cluster.kfd.sighup.io/module: opa
    cluster.kfd.sighup.io/policy-type: gatekeeper
spec:
  podSelector:
    matchLabels:
      app: gatekeeper-policy-manager
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: pomerium
      podSelector:
        matchLabels:
          app: pomerium
    ports:
    - protocol: TCP
      port: 8080
{{- end }}
{{- if and (ne .spec.distribution.modules.auth.provider.type "sso") (ne .spec.distribution.modules.ingress.haproxy.type "none") }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: gpm-ingress-haproxy
  namespace: gatekeeper-system
  labels:
    cluster.kfd.sighup.io/module: opa
    cluster.kfd.sighup.io/policy-type: gatekeeper
spec:
  podSelector:
    matchLabels:
      app: gatekeeper-policy-manager
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: ingress-haproxy
      podSelector:
        matchLabels:
          k8s-app: haproxy-ingress
    ports:
    - protocol: TCP
      port: 8080
{{- end }}
{{- if and (ne .spec.distribution.modules.auth.provider.type "sso") (ne .spec.distribution.modules.ingress.nginx.type "none") }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: gpm-ingress-nginx
  namespace: gatekeeper-system
  labels:
    cluster.kfd.sighup.io/module: opa
    cluster.kfd.sighup.io/policy-type: gatekeeper
spec:
  podSelector:
    matchLabels:
      app: gatekeeper-policy-manager
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: ingress-nginx
      podSelector:
        matchLabels:
          app.kubernetes.io/name: ingress-nginx
    ports:
    - protocol: TCP
      port: 8080
{{- end }}
