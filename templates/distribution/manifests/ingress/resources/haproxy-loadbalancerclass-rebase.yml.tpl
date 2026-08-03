# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- if eq .spec.distribution.common.provider.type "eks" }}
{{- if ne .spec.distribution.modules.ingress.haproxy.type "none" }}
---
apiVersion: kapp.k14s.io/v1alpha1
kind: Config
metadata:
  # this resource has no metadata of its own; this is only here
  # because kustomize requires metadata.name on every resource it accumulates.
  name: haproxy-loadbalancerclass-rebase

rebaseRules:
  - path: [spec, loadBalancerClass]
    type: copy
    sources: [existing]
    resourceMatchers:
      - apiVersionKindMatcher:
          apiVersion: v1
          kind: Service
{{- end }}
{{- end }}
