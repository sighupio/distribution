# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.
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
              value: "{{- template "controlPlaneAddress" (dict "config" . "args" "host") -}}"
            - name: KUBERNETES_SERVICE_PORT
              value: "{{- template "controlPlaneAddress" (dict "config" . "args" "port") -}}"
        - name: clean-cilium-state
          env:
            - name: KUBERNETES_SERVICE_HOST
              value: "{{- template "controlPlaneAddress" (dict "config" . "args" "host") -}}"
            - name: KUBERNETES_SERVICE_PORT
              value: "{{- template "controlPlaneAddress" (dict "config" . "args" "port") -}}"
      containers:
        - name: cilium-agent
          env:
            - name: KUBERNETES_SERVICE_HOST
              value: "{{- template "controlPlaneAddress" (dict "config" . "args" "host") -}}"
            - name: KUBERNETES_SERVICE_PORT
              value: "{{- template "controlPlaneAddress" (dict "config" . "args" "port") -}}"
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
              value: "{{- template "controlPlaneAddress" (dict "config" . "args" "host") -}}"
            - name: KUBERNETES_SERVICE_PORT
              value: "{{- template "controlPlaneAddress" (dict "config" . "args" "port") -}}"
