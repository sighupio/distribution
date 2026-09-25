{{- $enabled := and (eq .spec.distribution.common.provider.type "none" "immutable") (hasKeyAny .spec "kubernetes") (eq (.spec | digAny "distribution" "modules" "utilities" "headlamp" "type" "none") "token-auth") }}
{{- /* sso mode uses resources/headlamp-rbac.yml.tpl instead, bound to an OIDC group rather than this ServiceAccount */ -}}
{{- if $enabled }}
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: headlamp
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: {{ .spec.distribution.modules.utilities.headlamp.clusterRole }}
subjects:
  - kind: ServiceAccount
    name: headlamp
    namespace: headlamp
{{- end }}
