# Copyright (c) 2024-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.
---
apiVersion: monitoring.coreos.com/v1alpha1
kind: PrometheusAgent
metadata:
  name: sender
  namespace: monitoring
spec:
  # image should be the same as the one used in prometheus-operated
  image: registry.sighup.io/fury/prometheus/prometheus:v3.5.0
  # version: 2.46.0
  replicas: 2
  externalLabels:
    k8s_cluster: {{ .metadata.name }}
  {{- if hasKeyAny .spec.distribution.modules.monitoring.prometheusAgent "resources" }}
  resources:
    {{ .spec.distribution.modules.monitoring.prometheusAgent.resources | toYaml | indent 4 | trim }}
  {{- end }}

  {{- if hasKeyAny .spec.distribution.modules.monitoring.prometheusAgent "remoteWrite" }}
  remoteWrite:
    {{ .spec.distribution.modules.monitoring.prometheusAgent.remoteWrite | toYaml | indent 4 | trim }}
  {{- end }}
  serviceAccountName: prometheus-agent
  podMonitorNamespaceSelector: {}
  podMonitorSelector: {}
  probeNamespaceSelector: {}
  probeSelector: {}
  serviceMonitorNamespaceSelector: {}
  serviceMonitorSelector: {}
  scrapeConfigSelector: {}

  {{- $prometheusAgentArgs := dict "module" "monitoring" "package" "prometheusAgent" "spec" .spec }}
  tolerations:
    {{ template "tolerations" merge (dict "indent" 4) $prometheusAgentArgs }}
  nodeSelector:
    {{ template "nodeSelector" merge (dict "indent" 4) $prometheusAgentArgs }}
