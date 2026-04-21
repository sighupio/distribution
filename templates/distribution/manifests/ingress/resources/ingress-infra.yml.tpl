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
    cluster.kfd.sighup.io/useful-link.url: https://{{ template "forecastleUrl" .spec }}
    cluster.kfd.sighup.io/useful-link.name: "Forecastle"
    forecastle.stakater.com/expose: "true"
    forecastle.stakater.com/appName: "Forecastle"
    {{ if and (not .spec.distribution.modules.ingress.overrides.ingresses.forecastle.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
    forecastle.stakater.com/group: "forecastle"
    {{ end }}
    forecastle.stakater.com/icon: "https://raw.githubusercontent.com/stakater/Forecastle/master/assets/web/forecastle-round-100px.png"
    {{ if not .spec.distribution.modules.ingress.overrides.ingresses.forecastle.disableAuth }}{{ template "ingressAuth" . }}{{ end }}
    {{ template "certManagerClusterIssuer" . }}
    {{ template "byoicAnnotations" . }}
  name: forecastle
  {{ if and (not .spec.distribution.modules.ingress.overrides.ingresses.forecastle.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
  namespace: pomerium
  {{ else }}
  namespace: forecastle
  {{ end }}
spec:
  ingressClassName: {{ template "ingressClass" (dict "module" "ingress" "package" "forecastle" "type" "internal" "spec" .spec) }}
  rules:
    - host: {{ template "forecastleUrl" .spec }}
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
          {{ if and (not .spec.distribution.modules.ingress.overrides.ingresses.forecastle.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
            service:
              name: pomerium
              port:
                number: 80
          {{ else }}
            service:
              name: forecastle
              port:
                name: http
          {{ end }}
{{- template "ingressTls" (dict "module" "ingress" "package" "forecastle" "prefix" "directory." "spec" .spec) }}
