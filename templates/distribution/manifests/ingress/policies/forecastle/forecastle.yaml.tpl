# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $haproxyType := .spec.distribution.modules.ingress.haproxy.type }}
{{- $nginxType := .spec.distribution.modules.ingress.nginx.type }}
{{- $isSSO := eq .spec.distribution.modules.auth.provider.type "sso" }}
{{- $isBYOIC := .spec.distribution.modules.ingress.byoic.enabled }}

{{- if $isSSO }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: forecastle-ingress-pomerium
  namespace: forecastle
  labels:
    cluster.kfd.sighup.io/module: ingress
spec:
  podSelector:
    matchLabels:
      app: forecastle
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
        - port: 3000
          protocol: TCP
{{- else }}
  {{- if ne $nginxType "none" }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: forecastle-ingress-nginx
  namespace: forecastle
  labels:
    cluster.kfd.sighup.io/module: ingress
spec:
  podSelector:
    matchLabels:
      app: forecastle
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: ingress-nginx
          podSelector:
            matchLabels:
    {{- if eq $nginxType "dual" }}
              app: ingress
    {{- else }}
              app: ingress-nginx
    {{- end }}
      ports:
        - port: 3000
          protocol: TCP
  {{- end }}

  {{- if ne $haproxyType "none" }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: forecastle-ingress-haproxy
  namespace: forecastle
  labels:
    cluster.kfd.sighup.io/module: ingress
spec:
  podSelector:
    matchLabels:
      app: forecastle
  policyTypes:
    - Ingress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: ingress-haproxy
          podSelector:
            matchLabels:
              app.kubernetes.io/name: kubernetes-ingress
              app.kubernetes.io/instance: haproxy-ingress
      ports:
        - port: 3000
          protocol: TCP
  {{- end }}

  {{- if $isBYOIC }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: forecastle-ingress-byoic
  namespace: forecastle
  labels:
    cluster.kfd.sighup.io/module: ingress
spec:
  podSelector:
    matchLabels:
      app: forecastle
  policyTypes:
    - Ingress
  ingress:
    - ports:
        - port: 3000
          protocol: TCP
  {{- end }}
{{- end }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: forecastle-egress-kube-apiserver
  namespace: forecastle
  labels:
    cluster.kfd.sighup.io/module: ingress
spec:
  podSelector:
    matchLabels:
      app: forecastle
  policyTypes:
    - Egress
  egress:
  - ports:
    - port: 6443
      protocol: TCP
