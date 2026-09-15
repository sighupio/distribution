# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- if and (eq .spec.distribution.modules.policy.type "gatekeeper") (eq .spec.distribution.modules.auth.provider.type "sso") }}
---
# GPM's RBAC-aligned views ask the API server, per logged-in person, what that person may read, and
# render only that. GPM keeps reading the cluster with its own ServiceAccount and never acts as the
# user, which is why this is `create subjectaccessreviews` and not the `impersonate` verb.
#
# Granted only in sso mode, because the reviews need an identity and only Pomerium supplies one.
# module-policy does not carry this rule, so without it GPM answers every reader with "GPM cannot
# confirm what you are allowed to see".
#
# The feature stays off until GPM_RBAC_FILTERING is set: the grant makes it available, it does not
# turn it on. See the GPM README, "RBAC-aligned views", for what else it needs.
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: gatekeeper-policy-manager-subjectaccessreviews
  labels:
    cluster.kfd.sighup.io/module: opa
rules:
  - apiGroups: ["authorization.k8s.io"]
    resources: ["subjectaccessreviews"]
    verbs: ["create"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: gatekeeper-policy-manager-subjectaccessreviews
  labels:
    cluster.kfd.sighup.io/module: opa
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: gatekeeper-policy-manager-subjectaccessreviews
subjects:
  - kind: ServiceAccount
    name: gatekeeper-policy-manager
    namespace: gatekeeper-system
{{- end }}
