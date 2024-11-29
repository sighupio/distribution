# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
{{- if eq .spec.distribution.modules.policy.type "gatekeeper" }}
  - gatekeeper
{{- end }}
{{- if eq .spec.distribution.modules.policy.type "kyverno" }}
  - kyverno
{{- end }}

