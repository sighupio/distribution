# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

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
      containers:
      - name: opensearch
      {{- if hasField . "spec.distribution.modules.logging.opensearch.resources" }}
        resources:
          {{ .spec.distribution.modules.logging.opensearch.resources | toYaml | indent 10 | trim }}
      {{- end }}
  volumeClaimTemplates:
  - metadata:
      name: opensearch-cluster-master
    spec:
      accessModes:
      - ReadWriteOnce
      resources:
        requests:
          storage: {{ .spec.distribution.modules.logging.opensearch.storageSize }}
{{- end }}
