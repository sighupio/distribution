# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $gatekeeperArgs := dict "module" "policy" "package" "gatekeeper" "spec" .spec -}}
{{- $kyvernoArgs := dict "module" "policy" "package" "kyverno" "spec" .spec -}}
{{- if eq .spec.distribution.modules.policy.type "gatekeeper" }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gatekeeper-audit
  namespace: gatekeeper-system
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $gatekeeperArgs }}
      tolerations:
        {{ template "tolerations" $gatekeeperArgs }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gatekeeper-controller-manager
  namespace: gatekeeper-system
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $gatekeeperArgs }}
      tolerations:
        {{ template "tolerations" $gatekeeperArgs }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gatekeeper-policy-manager
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $gatekeeperArgs }}
      tolerations:
        {{ template "tolerations" $gatekeeperArgs }}
{{- end }}
{{- if eq .spec.distribution.modules.policy.type "kyverno" }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kyverno-admission-controller
  namespace: kyverno
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $kyvernoArgs }}
      tolerations:
        {{ template "tolerations" $kyvernoArgs }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kyverno-background-controller
  namespace: kyverno
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $kyvernoArgs }}
      tolerations:
        {{ template "tolerations" $kyvernoArgs }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kyverno-cleanup-controller
  namespace: kyverno
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $kyvernoArgs }}
      tolerations:
        {{ template "tolerations" $kyvernoArgs }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kyverno-reports-controller
  namespace: kyverno
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $kyvernoArgs }}
      tolerations:
        {{ template "tolerations" $kyvernoArgs }}
{{- end }}
