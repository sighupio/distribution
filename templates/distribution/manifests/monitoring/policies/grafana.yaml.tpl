# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $monitoringType := .spec.distribution.modules.monitoring.type }}

# source: https://github.com/prometheus-operator/kube-prometheus/blob/main/manifests/grafana-networkPolicy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: grafana
  namespace: monitoring
  labels:
    cluster.kfd.sighup.io/module: monitoring
spec:
  egress:
  - {}
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app.kubernetes.io/name: prometheus
    ports:
    - port: 3000
      protocol: TCP
  podSelector:
    matchLabels:
      app.kubernetes.io/component: grafana
      app.kubernetes.io/name: grafana
      app.kubernetes.io/part-of: kube-prometheus
  policyTypes:
  - Egress
  - Ingress
---
{{- $nginxType := .spec.distribution.modules.ingress.nginx.type }}
{{- $haproxyType := .spec.distribution.modules.ingress.haproxy.type }}
{{- $isSSO := eq .spec.distribution.modules.auth.provider.type "sso" }}
{{- $isBYOIC := .spec.distribution.modules.ingress.byoic.enabled }}

{{- if $isSSO }}
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: grafana-ingress-pomerium
  namespace: monitoring
  labels:
    cluster.kfd.sighup.io/module: monitoring
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/component: grafana
      app.kubernetes.io/name: grafana
      app.kubernetes.io/part-of: kube-prometheus
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
  name: grafana-ingress-nginx
  namespace: monitoring
  labels:
    cluster.kfd.sighup.io/module: monitoring
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/component: grafana
      app.kubernetes.io/name: grafana
      app.kubernetes.io/part-of: kube-prometheus
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
  name: grafana-ingress-haproxy
  namespace: monitoring
  labels:
    cluster.kfd.sighup.io/module: monitoring
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/component: grafana
      app.kubernetes.io/name: grafana
      app.kubernetes.io/part-of: kube-prometheus
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
  name: grafana-ingress-byoic
  namespace: monitoring
  labels:
    cluster.kfd.sighup.io/module: monitoring
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/component: grafana
      app.kubernetes.io/name: grafana
      app.kubernetes.io/part-of: kube-prometheus
  policyTypes:
    - Ingress
  ingress:
    - ports:
        - port: 3000
          protocol: TCP
  {{- end }}
{{- end }}
---
