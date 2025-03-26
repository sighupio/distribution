# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $opensearchArgs := dict "module" "logging" "package" "opensearch" "spec" .spec -}}
{{- $minioArgs := dict "module" "logging" "package" "minio" "spec" .spec -}}
{{- $operatorArgs := dict "module" "logging" "package" "operator" "spec" .spec -}}
{{- $lokiArgs := dict "module" "logging" "package" "loki" "spec" .spec -}}

{{- if eq .spec.distribution.modules.logging.type "opensearch" }}
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: opensearch-cluster-master
  namespace: logging
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $opensearchArgs }}
      tolerations:
        {{ template "tolerations" $opensearchArgs }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: opensearch-dashboards
  namespace: logging
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $opensearchArgs }}
      tolerations:
        {{ template "tolerations" $opensearchArgs }}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: ism-policy-cronjob
  namespace: logging
spec:
  jobTemplate:
    spec:
      template:
        spec:
          nodeSelector:
            {{ template "nodeSelector" $operatorArgs }}
          tolerations:
            {{ template "tolerations" ( merge (dict "indent" 12) $operatorArgs ) }}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: index-patterns-cronjob
  namespace: logging
spec:
  jobTemplate:
    spec:
      template:
        spec:
          nodeSelector:
            {{ template "nodeSelector" $operatorArgs }}
          tolerations:
            {{ template "tolerations" ( merge (dict "indent" 12) $operatorArgs ) }}
{{- end }}
{{- if eq .spec.distribution.modules.logging.type "loki" }}
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: loki-distributed-ingester
  namespace: logging
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $lokiArgs }}
      tolerations:
        {{ template "tolerations" $lokiArgs }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: loki-distributed-querier
  namespace: logging
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $lokiArgs }}
      tolerations:
        {{ template "tolerations" $lokiArgs }}
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: loki-distributed-compactor
  namespace: logging
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $lokiArgs }}
      tolerations:
        {{ template "tolerations" $lokiArgs }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: loki-distributed-distributor
  namespace: logging
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $lokiArgs }}
      tolerations:
        {{ template "tolerations" $lokiArgs }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: loki-distributed-gateway
  namespace: logging
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $lokiArgs }}
      tolerations:
        {{ template "tolerations" $lokiArgs }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: loki-distributed-query-frontend
  namespace: logging
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $lokiArgs }}
      tolerations:
        {{ template "tolerations" $lokiArgs }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: loki-distributed-query-frontend
  namespace: logging
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $lokiArgs }}
      tolerations:
        {{ template "tolerations" $lokiArgs }}
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: loki-distributed-index-gateway
  namespace: logging
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $lokiArgs }}
      tolerations:
        {{ template "tolerations" $lokiArgs }}
{{- end }}
{{- if or (eq .spec.distribution.modules.logging.type "loki") (eq .spec.distribution.modules.logging.type "opensearch") }}
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: minio-logging
  namespace: logging
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $minioArgs }}
      tolerations:
        {{ template "tolerations" $minioArgs }}
---
apiVersion: batch/v1
kind: Job
metadata:
  name: minio-logging-buckets-setup
  namespace: logging
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $minioArgs }}
      tolerations:
        {{ template "tolerations" $minioArgs }}
{{- end }}
---
apiVersion: logging.banzaicloud.io/v1beta1
kind: Logging
metadata:
  name: infra
spec:
  fluentd:
    nodeSelector:
      {{ template "nodeSelector" $operatorArgs }}
    tolerations:
      {{ template "tolerations" ( merge (dict "indent" 6)  $operatorArgs) }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: logging-operator
  namespace: logging
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $operatorArgs }}
      tolerations:
        {{ template "tolerations" $operatorArgs }}
---
apiVersion: logging-extensions.banzaicloud.io/v1alpha1
kind: EventTailer
metadata:
  name: kubernetes
spec:
  workloadOverrides:
    nodeSelector:
      {{ template "nodeSelector" $operatorArgs }}
    tolerations:
      {{ template "tolerations" ( merge (dict "indent" 6)  $operatorArgs) }}
