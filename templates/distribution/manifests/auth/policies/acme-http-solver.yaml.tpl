# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $nginxType := .spec.distribution.modules.ingress.nginx.type }}
{{- $haproxyType := .spec.distribution.modules.ingress.haproxy.type }}
{{- $isBYOIC := .spec.distribution.modules.ingress.byoic.enabled }}

{{- if ne $nginxType "none" }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: acme-httpsolver-ingress-nginx
  namespace: pomerium
  labels:
    cluster.kfd.sighup.io/module: auth
    cluster.kfd.sighup.io/auth-provider-type: sso
spec:
  podSelector:
    matchLabels:
      app: cert-manager
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
        - port: 8089
          protocol: TCP
{{- end }}
{{- if ne $haproxyType "none" }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: acme-httpsolver-ingress-haproxy
  namespace: pomerium
  labels:
    cluster.kfd.sighup.io/module: auth
    cluster.kfd.sighup.io/auth-provider-type: sso
spec:
  podSelector:
    matchLabels:
      app: cert-manager
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
        - port: 8089
          protocol: TCP
{{- end }}
{{- if $isBYOIC }}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: acme-httpsolver-ingress-byoic
  namespace: pomerium
  labels:
    cluster.kfd.sighup.io/module: auth
    cluster.kfd.sighup.io/auth-provider-type: sso
spec:
  podSelector:
    matchLabels:
      app: cert-manager
  policyTypes:
    - Ingress
  ingress:
    - ports:
        - port: 8089
          protocol: TCP
{{- end }}
---
