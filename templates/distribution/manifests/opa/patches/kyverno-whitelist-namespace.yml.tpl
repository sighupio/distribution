# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $defaultNamespaces := (list "kube-system" "kyverno" "logging" "monitoring" "ingress-nginx" "cert-manager" "tigera-operator" "calico-system" "calico-api" "vmware-system-csi" "pomerium" "tracing") }}
{{- $newWebhook := dict "key" "kubernetes.io/metadata.name" "operator" "NotIn" "values" ((concat $defaultNamespaces .spec.distribution.modules.policy.kyverno.additionalExcludedNamespaces) | uniq) }}
{{- $kwhitelist := dict "matchExpressions" (list $newWebhook) }}
{{- $kwhitelist := dict "namespaceSelector" $kwhitelist | toJson | quote }}

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: kyverno
  namespace: kyverno
data:
  webhooks: {{ $kwhitelist }}