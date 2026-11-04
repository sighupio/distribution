# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $nginxType := .spec.distribution.modules.ingress.nginx.type }}
{{- $haproxyType := .spec.distribution.modules.ingress.haproxy.type }}
{{- $isSSO := eq .spec.distribution.modules.utilities.headlamp.type "sso" }}

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: headlamp-egress-kube-apiserver
  namespace: headlamp
  labels:
    cluster.kfd.sighup.io/module: utilities
spec:
  policyTypes:
    - Egress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: headlamp
  egress:
    - ports:
        - port: 6443
          protocol: TCP
{{- if $isSSO }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: headlamp-ingress-pomerium
  namespace: headlamp
  labels:
    cluster.kfd.sighup.io/module: utilities
spec:
  policyTypes:
    - Ingress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: headlamp
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: pomerium
          podSelector:
            matchLabels:
              app: pomerium
      ports:
        - port: 4466
          protocol: TCP
{{- else }}
  {{- if ne $nginxType "none" }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: headlamp-ingress-nginx
  namespace: headlamp
  labels:
    cluster.kfd.sighup.io/module: utilities
spec:
  policyTypes:
    - Ingress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: headlamp
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
        - port: 4466
          protocol: TCP
  {{- end }}
  {{- if ne $haproxyType "none" }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: headlamp-ingress-haproxy
  namespace: headlamp
  labels:
    cluster.kfd.sighup.io/module: utilities
spec:
  policyTypes:
    - Ingress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: headlamp
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
        - port: 4466
          protocol: TCP
  {{- end }}
  {{- if .spec.distribution.modules.ingress.byoic.enabled }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: headlamp-ingress-byoic
  namespace: headlamp
  labels:
    cluster.kfd.sighup.io/module: utilities
spec:
  policyTypes:
    - Ingress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: headlamp
  ingress:
    - ports:
        - port: 4466
          protocol: TCP
  {{- end }}
{{- end }}
