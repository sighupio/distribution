# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  labels:
    cluster.kfd.sighup.io/useful-link.enable: "true"
  annotations:
    cluster.kfd.sighup.io/useful-link.url: https://{{ template "whiskerUrl" .spec }}
    cluster.kfd.sighup.io/useful-link.name: "Calico Whisker UI"
    forecastle.stakater.com/expose: "true"
    forecastle.stakater.com/appName: "Calico Whisker UI"
    forecastle.stakater.com/icon: "https://docs.tigera.io/img/calico-logo.png"
    {{ if and (not .spec.distribution.modules.ingress.overrides.ingresses.forecastle.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
    forecastle.stakater.com/group: "networking"
    {{ end }}
    {{ if not .spec.distribution.modules.networking.overrides.ingresses.whisker.disableAuth }}{{ template "ingressAuth" . }}{{ end }}
    {{ template "certManagerClusterIssuer" . }}
    {{ template "byoicAnnotations" . }}
  name: whisker
  {{ if and (not .spec.distribution.modules.networking.overrides.ingresses.whisker.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
  namespace: pomerium
  {{ else }}
  namespace: calico-system
  {{ end }}
spec:
  ingressClassName: {{ template "ingressClass" (dict "module" "networking" "package" "whisker" "type" "internal" "spec" .spec) }}
  rules:
    - host: {{ template "whiskerUrl" .spec }}
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
          {{ if and (not .spec.distribution.modules.networking.overrides.ingresses.whisker.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
            service:
              name: pomerium
              port:
                number: 80
          {{ else }}
            service:
              name: whisker
              port:
                number: 8081
          {{ end }}
{{- template "ingressTls" (dict "module" "networking" "package" "whisker" "prefix" "whisker." "spec" .spec) }}
