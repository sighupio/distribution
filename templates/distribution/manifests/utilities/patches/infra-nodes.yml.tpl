{{- $enabled := and (eq .spec.distribution.common.provider.type "none" "immutable") (hasKeyAny .spec "kubernetes") (has (.spec | digAny "distribution" "modules" "utilities" "headlamp" "type" "none") (list "token-auth" "sso")) }}
{{- if $enabled }}
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{ $headlampArgs := dict "module" "utilities" "package" "headlamp" "spec" .spec }}

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: headlamp
  namespace: headlamp
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $headlampArgs }}
      tolerations:
        {{ template "tolerations" $headlampArgs }}
{{- end }}
