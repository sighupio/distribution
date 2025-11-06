# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: k8s
  namespace: monitoring
spec:
  externalLabels:
    k8s_cluster: {{ .metadata.name }}
  externalUrl: https://{{ template "prometheusUrl" .spec }}
  {{- if hasField . "spec.distribution.modules.monitoring.prometheus.resources" }}
  resources:
    {{ .spec.distribution.modules.monitoring.prometheus.resources | toYaml | indent 4 | trim }}
  {{- end }}
  {{- if hasField . "spec.distribution.modules.monitoring.prometheus.remoteWrite" }}
  remoteWrite:
    {{ .spec.distribution.modules.monitoring.prometheus.remoteWrite | toYaml | indent 4 | trim }}
  {{- end }}
  retention: {{ .spec.distribution.modules.monitoring.prometheus.retentionTime }}
  retentionSize: {{ .spec.distribution.modules.monitoring.prometheus.retentionSize }}
  storage:
    volumeClaimTemplate:
      spec:
        accessModes:
          - ReadWriteOnce
        resources:
          requests:
            storage: {{ .spec.distribution.modules.monitoring.prometheus.storageSize }}
