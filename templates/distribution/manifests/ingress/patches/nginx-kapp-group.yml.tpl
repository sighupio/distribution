# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{ if eq .spec.distribution.modules.ingress.nginx.type "dual" -}}
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ingress-nginx-controller-external
  namespace: ingress-nginx
  annotations:
    kapp.k14s.io/change-group: "nginx-controllers"
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ingress-nginx-controller-internal
  namespace: ingress-nginx
  annotations:
    kapp.k14s.io/change-group: "nginx-controllers"
{{- else if eq .spec.distribution.modules.ingress.nginx.type "single" -}}
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ingress-nginx-controller
  namespace: ingress-nginx
  annotations:
    kapp.k14s.io/change-group: "nginx-controllers"
{{- end }}
