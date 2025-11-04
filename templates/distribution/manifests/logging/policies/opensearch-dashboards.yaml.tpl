# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: opensearch-dashboards-egress-opensearch
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
    cluster.kfd.sighup.io/logging-type: opensearch
spec:
  policyTypes:
    - Egress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: opensearch-dashboards
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: logging
          podSelector:
            matchLabels:
              app.kubernetes.io/name: opensearch
      ports:
        - port: 9200
          protocol: TCP
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: opensearch-dashboards-ingress-jobs
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
    cluster.kfd.sighup.io/logging-type: opensearch
spec:
  policyTypes:
    - Ingress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: opensearch-dashboards
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app.kubernetes.io/name: opensearch-dashboards
              app.kubernetes.io/instance: opensearch-dashboards
      ports:
        - port: 5601
          protocol: TCP
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: opensearch-dashboards-ingress-nginx
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
    cluster.kfd.sighup.io/logging-type: opensearch
spec:
  policyTypes:
    - Ingress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: opensearch-dashboards
  ingress:
    - from:
      - namespaceSelector:
{{- if (eq .spec.distribution.modules.auth.provider.type "sso") }}
          matchLabels:
            kubernetes.io/metadata.name: pomerium
{{ else }}
          matchLabels:
            kubernetes.io/metadata.name: ingress-nginx
{{- end }}
        podSelector:
          matchLabels:
{{- if (eq .spec.distribution.modules.auth.provider.type "sso") }}
            app: pomerium
{{- else if eq .spec.distribution.modules.ingress.nginx.type "dual" }}
            app: ingress
{{- else if eq .spec.distribution.modules.ingress.nginx.type "single" }}
            app: ingress-nginx
{{- end }}
      ports:
        - port: 5601
          protocol: TCP
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: jobs-egress-opensearch-dashboards
  namespace: logging
  labels:
    cluster.kfd.sighup.io/module: logging
    cluster.kfd.sighup.io/logging-type: opensearch
spec:
  policyTypes:
    - Egress
  podSelector:
    matchLabels:
      app.kubernetes.io/name: opensearch-dashboards
      app.kubernetes.io/instance: opensearch-dashboards
  egress:
    - to:
        - podSelector:
            matchLabels:
              app.kubernetes.io/name: opensearch-dashboards
      ports:
        - port: 5601
          protocol: TCP
---
