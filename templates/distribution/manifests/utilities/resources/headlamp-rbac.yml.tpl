# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $enabled := and (eq .spec.distribution.common.provider.type "none" "immutable") (hasKeyAny .spec "kubernetes") (eq (.spec | digAny "distribution" "modules" "utilities" "headlamp" "type" "none") "sso") }}
{{- if $enabled }}

{{- /* The API server prefixes the OIDC groups, so the bindings must use the prefixed name. Same */}}
{{- /* precedence as oidc_groups_prefix in kubernetes/{onpremises,immutable}/hosts.yaml.tpl: */}}
{{- /* groups_prefix, then the deprecated group_prefix, then the installer default "oidc:". */}}
{{- $groupsPrefix := or (.spec | digAny "kubernetes" "advanced" "oidc" "groups_prefix" "") (.spec | digAny "kubernetes" "advanced" "oidc" "group_prefix" "") "oidc:" }}
{{- $group := print $groupsPrefix .spec.distribution.modules.utilities.headlamp.oidcGroup }}
{{- /* services/proxy names of the observability backends installed on this cluster. The */}}
{{- /* role and binding below are created only when this list has entries: a rule without */}}
{{- /* resourceNames would grant services/proxy on every service. */}}
{{- $serviceProxyNames := list }}
{{- if ne .spec.distribution.modules.monitoring.type "none" }}
{{- $serviceProxyNames = append $serviceProxyNames "prometheus-k8s" }}
{{- $serviceProxyNames = append $serviceProxyNames "prometheus-k8s:9090" }}
{{- end }}
{{- if and (eq .spec.distribution.modules.logging.type "loki") (.checks.storageClassAvailable) }}
{{- $serviceProxyNames = append $serviceProxyNames "loki-stack" }}
{{- $serviceProxyNames = append $serviceProxyNames "loki-stack:3100" }}
{{- end }}
{{- if and (eq .spec.distribution.modules.logging.type "opensearch") (.checks.storageClassAvailable) }}
{{- $serviceProxyNames = append $serviceProxyNames "opensearch-cluster-master" }}
{{- $serviceProxyNames = append $serviceProxyNames "opensearch-cluster-master:9200" }}
{{- end }}

---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: sd-ui-reader
rules:
  - apiGroups: [""]
    resources:
      - namespaces
      - nodes
      - pods
      - services
      - events
      - endpoints
      - persistentvolumeclaims
      - configmaps
    verbs: ["get", "list", "watch"]
  # Node CPU/memory tiles on the sd-core landing page (served by metrics-server).
  - apiGroups: ["metrics.k8s.io"]
    resources: ["nodes"]
    verbs: ["get", "list"]
  - apiGroups: ["apps"]
    resources: ["deployments", "daemonsets", "statefulsets", "replicasets"]
    verbs: ["get", "list", "watch"]
  - apiGroups: ["networking.k8s.io"]
    resources: ["ingresses"]
    verbs: ["get", "list", "watch"]
  # Kyverno PolicyReports / Gatekeeper constraints (sd-policy). Harmless no-ops if the
  # corresponding CRDs aren't installed.
  - apiGroups: ["wgpolicyk8s.io"]
    resources: ["policyreports", "clusterpolicyreports"]
    verbs: ["get", "list"]
  - apiGroups: ["constraints.gatekeeper.sh"]
    resources: ["*"]
    verbs: ["get", "list"]
  # Velero backups/schedules/restores (sd-backups). Harmless no-op if Velero isn't installed.
  - apiGroups: ["velero.io"]
    resources: ["backups", "schedules", "restores"]
    verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: sd-ui-reader
subjects:
  - kind: Group
    name: {{ $group }}
    apiGroup: rbac.authorization.k8s.io
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: sd-ui-reader
{{- if $serviceProxyNames }}
---
# services/proxy access to the observability backends actually installed on this cluster
# (sd-logs, sd-certificates, sd-events). Never covered by the built-in `view` role; both the
# bare and port-suffixed resourceNames forms are required.
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: sd-ui-service-proxy
rules:
  - apiGroups: [""]
    resources: ["services/proxy"]
    resourceNames:
{{- range $serviceProxyNames }}
      - {{ . | quote }}
{{- end }}
    verbs: ["get", "create"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: sd-ui-service-proxy
subjects:
  - kind: Group
    name: {{ $group }}
    apiGroup: rbac.authorization.k8s.io
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: sd-ui-service-proxy
{{- end }}
---
# sd-core reads distribution metadata from the furyctl secrets. `view` excludes secrets, so
# this is a narrow, name-scoped Role rather than a blanket secrets grant.
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: sd-ui-furyctl-secrets-reader
  namespace: kube-system
rules:
  - apiGroups: [""]
    resources: ["secrets"]
    resourceNames: ["furyctl-kfd", "furyctl-config"]
    verbs: ["get"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: sd-ui-furyctl-secrets-reader
  namespace: kube-system
subjects:
  - kind: Group
    name: {{ $group }}
    apiGroup: rbac.authorization.k8s.io
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: sd-ui-furyctl-secrets-reader
{{- end }}
