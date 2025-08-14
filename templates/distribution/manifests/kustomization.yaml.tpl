# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
{{- if or (ne .spec.distribution.modules.auth.provider.type "none") .spec.distribution.modules.auth.oidcKubernetesAuth.enabled  }}
  - auth
{{- end }}
{{- if eq .spec.distribution.common.provider.type "eks" }}
  - aws
{{- end }}
{{- if and (ne .spec.distribution.modules.dr.type "none") (.checks.storageClassAvailable) }}
  - dr
{{- end }}
  - ingress
{{- if and (ne .spec.distribution.modules.logging.type "none") (.checks.storageClassAvailable) }}
  - logging
{{- end }}
{{- if ne .spec.distribution.modules.monitoring.type "none" }}
  - monitoring
{{- end }}
{{- if eq .spec.distribution.common.provider.type "eks" }}
  - networking
{{- end }}
{{- if and (ne .spec.distribution.modules.networking.type "none") (eq .spec.distribution.common.provider.type "none" ) }}
  - networking
{{- end }}
{{- if ne .spec.distribution.modules.policy.type "none" }}
  - opa
{{- end }}
{{- if and (eq .spec.distribution.modules.tracing.type "tempo") (.checks.storageClassAvailable) }}
  - tracing
{{- end }}

{{- if .spec.distribution.customPatches.patchesStrategicMerge }}
patchesStrategicMerge:
  {{ .spec.distribution.customPatches.patchesStrategicMerge | toYaml | indent 2 | trim -}}
{{- end }}

{{- if .spec.distribution.customPatches.patches }}
patches:
  {{ .spec.distribution.customPatches.patches | toYaml | indent 2 | trim -}}
{{- end }}

{{- if .spec.distribution.customPatches.secretGenerator }}
secretGenerator:
  {{ .spec.distribution.customPatches.secretGenerator | toYaml | indent 2 | trim -}}
{{- end }}

{{- if .spec.distribution.customPatches.configMapGenerator }}
configMapGenerator:
  {{ .spec.distribution.customPatches.configMapGenerator | toYaml | indent 2 | trim  -}}
{{- end }}

{{- if .spec.distribution.customPatches.images }}
images:
  {{ .spec.distribution.customPatches.images | toYaml | indent 2 | trim  -}}
{{- end }}
