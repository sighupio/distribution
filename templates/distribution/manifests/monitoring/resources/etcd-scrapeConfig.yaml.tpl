
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.


{{- if eq .spec.distribution.common.provider.type "none" }}
{{- if hasKeyAny .spec "kubernetes" }}
{{- if index .spec.kubernetes "etcd" }}
---
apiVersion: monitoring.coreos.com/v1alpha1
kind: ScrapeConfig
metadata:
  name: external-etcd
  namespace: monitoring
  labels:
    prometheus: k8s
spec:
  staticConfigs:
    - labels:
        job: etcd-metrics
      targets:
        {{- range $h := .spec.kubernetes.etcd.hosts }}
        - {{ $h.ip }}:2378
        {{- end }}
{{- end }}
{{- end }}
{{- end }}
