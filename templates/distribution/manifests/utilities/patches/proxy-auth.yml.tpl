{{- $enabled := and (eq .spec.distribution.common.provider.type "none" "immutable") (hasKeyAny .spec "kubernetes") (eq (.spec | digAny "distribution" "modules" "utilities" "headlamp" "type" "none") "sso") }}
{{- if $enabled }}
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- /* -proxy-auth=true makes Headlamp's own frontend trust the identity headers Pomerium sets */}}
{{- /* (see auth/resources/pomerium-policy.yml.tpl) instead of showing its "paste your token" */}}
{{- /* screen. This is a full replacement of args, not an addition: kustomize's strategic merge */}}
{{- /* has no merge key for a plain string list, so the base Deployment's args must be repeated */}}
{{- /* here in full or they would be dropped. */}}

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: headlamp
  namespace: headlamp
spec:
  template:
    spec:
      containers:
        - name: headlamp
          args:
            - "-in-cluster"
            - "-plugins-dir=/headlamp/plugins"
            - "-proxy-auth=true"
{{- end }}
