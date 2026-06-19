# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

{{ $loggingType := .spec.distribution.modules.logging.type }}
{{- $loki := index .spec.distribution.modules.logging "loki" }}
{{- $lokiBackend := "minio" }}
{{- if and $loki (index $loki "backend") }}{{ $lokiBackend = $loki.backend }}{{ end }}
{{- $deployMinio := or (eq $loggingType "opensearch") (and (eq $loggingType "loki") (eq $lokiBackend "minio")) }}

resources:
  - common.yaml
  - configs.yaml
  - fluentbit.yaml
  - fluentd.yaml
  - logging-operator.yaml
{{- if $deployMinio }}
  - minio.yaml
{{- end }}

{{- if eq $loggingType "loki" }}
  - loki.yaml
{{- end }}

{{- if eq $loggingType "opensearch" }}
  - opensearch-dashboards.yaml
  - opensearch.yaml
{{- end }}
