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
    cluster.kfd.sighup.io/useful-link.url: https://{{ template "hubbleUrl" .spec }}
    cluster.kfd.sighup.io/useful-link.name: "Cilium Hubble UI"
    forecastle.stakater.com/expose: "true"
    forecastle.stakater.com/appName: "Cilium Hubble UI"
    forecastle.stakater.com/icon: "https://cilium.io/static/hubble-light-1-812e65cbb72a7f4efed59fcea48df840.svg"
    {{ if and (not .spec.distribution.modules.ingress.overrides.ingresses.forecastle.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
    forecastle.stakater.com/group: "networking"
    {{ end }}
    {{ if not .spec.distribution.modules.networking.overrides.ingresses.hubble.disableAuth }}{{ template "ingressAuth" . }}{{ end }}
    {{ template "certManagerClusterIssuer" . }}
    {{ template "byoicAnnotations" . }}
  name: hubble
  {{ if and (not .spec.distribution.modules.networking.overrides.ingresses.hubble.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
  namespace: pomerium
  {{ else }}
  namespace: kube-system
  {{ end }}
spec:
  ingressClassName: {{ template "ingressClass" (dict "module" "networking" "package" "hubble" "type" "internal" "spec" .spec) }}
  rules:
    - host: {{ template "hubbleUrl" .spec }}
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
          {{ if and (not .spec.distribution.modules.networking.overrides.ingresses.hubble.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
            service:
              name: pomerium
              port:
                number: 80
          {{ else }}
            service:
              name: hubble-ui
              port:
                name: http
          {{ end }}
{{- template "ingressTls" (dict "module" "networking" "package" "hubble" "prefix" "hubble." "spec" .spec) }}
