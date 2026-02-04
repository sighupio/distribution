# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $haproxy := index .spec.distribution.modules.ingress "haproxy" }}
{{- if eq .spec.distribution.common.provider.type "eks" }}
{{- if and $haproxy (eq $haproxy.type "dual") }}
---
apiVersion: v1
kind: Service
metadata:
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-scheme: internal
    service.beta.kubernetes.io/aws-load-balancer-type: "external"
    service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "instance"
    service.beta.kubernetes.io/aws-load-balancer-proxy-protocol: "*"
  name: haproxy-ingress-internal
  namespace: ingress-haproxy
spec:
  type: LoadBalancer
  externalTrafficPolicy: Cluster
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: haproxy-ingress-internal
  namespace: ingress-haproxy
data:
  proxy-protocol: "0.0.0.0/0"
{{- end }}
{{- end }}
