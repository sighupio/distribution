# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- /*
  Since Tigera Operator v1.42 the Whisker policy created by the operator (`calico-system.whisker`) lives in the
  `calico-system` tier, which is evaluated before Kubernetes NetworkPolicies and denies by default. It has no ingress
  rules, so the allow rules for the ingress controller must be in the same tier: a Kubernetes NetworkPolicy would never
  be evaluated.
  The `crd.projectcalico.org/v1` API is used because its CRD is shipped by the networking module, while
  `projectcalico.org/v3` is served by the calico-apiserver and is not available on the first apply.
  The name and the `projectcalico.org/tier` label follow the format the calico-apiserver uses to store tiered policies.
*/}}

{{- $haproxyType := .spec.distribution.modules.ingress.haproxy.type }}
{{- $nginxType := .spec.distribution.modules.ingress.nginx.type }}
{{- $isSSO := eq .spec.distribution.modules.auth.provider.type "sso" }}
{{- $isBYOIC := .spec.distribution.modules.ingress.byoic.enabled }}
{{- $whiskerUsesPomerium := and (not .spec.distribution.modules.networking.overrides.ingresses.whisker.disableAuth) $isSSO }}

{{- if $whiskerUsesPomerium }}
---
apiVersion: crd.projectcalico.org/v1
kind: NetworkPolicy
metadata:
  name: calico-system.whisker-ingress-pomerium
  namespace: calico-system
  labels:
    cluster.kfd.sighup.io/module: networking
    projectcalico.org/tier: calico-system
spec:
  tier: calico-system
  order: 0
  selector: k8s-app == 'whisker'
  types:
    - Ingress
  ingress:
    - action: Allow
      protocol: TCP
      source:
        namespaceSelector: projectcalico.org/name == 'pomerium'
        selector: app == 'pomerium'
      destination:
        ports:
          - 8081
{{- else }}
  {{- if ne $nginxType "none" }}
---
apiVersion: crd.projectcalico.org/v1
kind: NetworkPolicy
metadata:
  name: calico-system.whisker-ingress-nginx
  namespace: calico-system
  labels:
    cluster.kfd.sighup.io/module: networking
    projectcalico.org/tier: calico-system
spec:
  tier: calico-system
  order: 0
  selector: k8s-app == 'whisker'
  types:
    - Ingress
  ingress:
    - action: Allow
      protocol: TCP
      source:
        namespaceSelector: projectcalico.org/name == 'ingress-nginx'
    {{- if eq $nginxType "dual" }}
        selector: app == 'ingress'
    {{- else }}
        selector: app == 'ingress-nginx'
    {{- end }}
      destination:
        ports:
          - 8081
  {{- end }}

  {{- if ne $haproxyType "none" }}
---
apiVersion: crd.projectcalico.org/v1
kind: NetworkPolicy
metadata:
  name: calico-system.whisker-ingress-haproxy
  namespace: calico-system
  labels:
    cluster.kfd.sighup.io/module: networking
    projectcalico.org/tier: calico-system
spec:
  tier: calico-system
  order: 0
  selector: k8s-app == 'whisker'
  types:
    - Ingress
  ingress:
    - action: Allow
      protocol: TCP
      source:
        namespaceSelector: projectcalico.org/name == 'ingress-haproxy'
        selector: app.kubernetes.io/name == 'kubernetes-ingress' && app.kubernetes.io/instance == 'haproxy-ingress'
      destination:
        ports:
          - 8081
  {{- end }}

  {{- if $isBYOIC }}
---
apiVersion: crd.projectcalico.org/v1
kind: NetworkPolicy
metadata:
  name: calico-system.whisker-ingress-byoic
  namespace: calico-system
  labels:
    cluster.kfd.sighup.io/module: networking
    projectcalico.org/tier: calico-system
spec:
  tier: calico-system
  order: 0
  selector: k8s-app == 'whisker'
  types:
    - Ingress
  ingress:
    - action: Allow
      protocol: TCP
      destination:
        ports:
          - 8081
  {{- end }}
{{- end }}
