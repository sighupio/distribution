# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- /* Defaults */ -}}
{{- $apiHost := "" }}
{{- $apiPort := "" }}

{{- /* Calculate the API server endpoint from the Kubernetes control plane address when the kind is OnPremises. */ -}}
{{- if and (eq .spec.distribution.common.provider.type "none") (hasKeyAny .spec "kubernetes") }}
  {{- $apiAddress := split ":" .spec.kubernetes.controlPlaneAddress }}
  {{- $apiHost = $apiAddress._0 }}
  {{- if eq (len $apiAddress) 2 }}
  {{- $apiPort = $apiAddress._1}}
  {{- else }}
      {{- /* If no port is specified in the address we assume the default HTTPS port 443 */ -}}
      {{- $apiPort = "443" }}
  {{- end }}
  {{- if or (eq $apiHost "") (eq $apiPort "") }}
    {{- fail "Error while calculating the Kubernetes API endpoint host and port. Calculated values are API Host: '$apiHost' and API Port: '$apiPort'" }}
  {{- end }}
{{- end }}
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  namespace: kube-system
  name: cilium
spec:
  template:
    spec:
      initContainers:
        - name: config
          env:
            - name: KUBERNETES_SERVICE_HOST
              value: "{{ $apiHost }}"
            - name: KUBERNETES_SERVICE_PORT
              value: "{{ $apiPort }}"
        - name: clean-cilium-state
          env:
            - name: KUBERNETES_SERVICE_HOST
              value: "{{ $apiHost }}"
            - name: KUBERNETES_SERVICE_PORT
              value: "{{ $apiPort }}"
      containers:
        - name: cilium-agent
          env:
            - name: KUBERNETES_SERVICE_HOST
              value: "{{ $apiHost }}"
            - name: KUBERNETES_SERVICE_PORT
              value: "{{ $apiPort }}"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cilium-operator
  namespace: kube-system
spec:
  template:
    spec:
      containers:
        - name: cilium-operator
          env:
            - name: KUBERNETES_SERVICE_HOST
              value: "{{ $apiHost }}"
            - name: KUBERNETES_SERVICE_PORT
              value: "{{ $apiPort }}"
