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
    cluster.kfd.sighup.io/useful-link.url: https://{{ template "gpmUrl" .spec }}
    cluster.kfd.sighup.io/useful-link.name: "Gatekeeper Policy Manager"
    forecastle.stakater.com/expose: "true"
    forecastle.stakater.com/appName: "Gatekeeper Policy Manager"
    {{ if and (not .spec.distribution.modules.ingress.overrides.ingresses.forecastle.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
    forecastle.stakater.com/group: "gatekeeper-system"
    {{ end }}
    forecastle.stakater.com/icon: "https://raw.githubusercontent.com/sighupio/gatekeeper-policy-manager/master/app/static-content/logo.svg"
    {{ if not .spec.distribution.modules.policy.overrides.ingresses.gpm.disableAuth }}{{ template "ingressAuth" . }}{{ end }}
    {{ template "certManagerClusterIssuer" . }}
    {{ template "byoicAnnotations" . }}
  name: gpm
  {{ if and (not .spec.distribution.modules.policy.overrides.ingresses.gpm.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
  namespace: pomerium
  {{ else }}
  namespace: gatekeeper-system
  {{ end }}
spec:
  ingressClassName: {{ template "ingressClass" (dict "module" "policy" "package" "gpm" "type" "internal" "spec" .spec) }}
  rules:
    - host: {{ template "gpmUrl" .spec }}
      http:
        paths:
        - path: /
          pathType: Prefix
          backend:
          {{ if and (not .spec.distribution.modules.policy.overrides.ingresses.gpm.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
            service:
              name: pomerium
              port:
                number: 80
          {{ else }}
            service:
              name: gatekeeper-policy-manager
              port:
                name: http
          {{ end }}
{{- template "ingressTls" (dict "module" "policy" "package" "gpm" "prefix" "gpm." "spec" .spec) }}
