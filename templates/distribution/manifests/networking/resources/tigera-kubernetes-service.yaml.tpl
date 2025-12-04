# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

kind: ConfigMap
apiVersion: v1
metadata:
  name: kubernetes-services-endpoint
  namespace: tigera-operator
data:
  KUBERNETES_SERVICE_HOST: "{{ template "controlPlaneAddress" (dict "config" . "args" "host") }}"
  KUBERNETES_SERVICE_PORT: "{{ template "controlPlaneAddress" (dict "config" . "args" "port") }}"
