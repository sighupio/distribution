# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.
{{- if or (ne .spec.distribution.modules.auth.provider.type "none") .spec.distribution.modules.auth.oidcKubernetesAuth.enabled -}}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  {{- if eq .spec.distribution.modules.ingress.nginx.tls.provider "certManager" }}
  annotations:
    {{ template "certManagerClusterIssuer" . }}
  {{- end }}
  name: dex
  namespace: kube-system
spec:
  # Needs to be externally available in order to act as callback from GitHub.
  ingressClassName: {{ template "ingressClass" (dict "module" "auth" "package" "dex" "type" "external" "spec" .spec) }}
  rules:
    - host: {{ template "dexUrl" .spec }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: dex
                port:
                  name: http
{{- template "ingressTlsAuth" (dict "module" "auth" "package" "dex" "prefix" "login." "spec" .spec) }}
{{- end }}

{{- if .spec.distribution.modules.auth.oidcKubernetesAuth.enabled }}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  labels:
    cluster.kfd.sighup.io/useful-link.enable: "true"
  annotations:
    cluster.kfd.sighup.io/useful-link.url: https://{{ template "gangplankUrl" .spec }}
    cluster.kfd.sighup.io/useful-link.name: "Gangplank"
    forecastle.stakater.com/expose: "true"
    forecastle.stakater.com/appName: "Gangplank - SSO Kubeconfig"
    forecastle.stakater.com/icon: "https://raw.githubusercontent.com/sighupio/distribution/refs/heads/main/docs/assets/black-logo.png"
  {{- if eq .spec.distribution.modules.ingress.nginx.tls.provider "certManager" }}
    {{ template "certManagerClusterIssuer" . }}
  {{- end }}
  name: gangplank
  namespace: kube-system
spec:
  # Needs to be externally available in order to act as callback from GitHub.
  ingressClassName: {{ template "ingressClass" (dict "module" "auth" "package" "gangplank" "type" "external" "spec" .spec) }}
  rules:
    - host: {{ template "gangplankUrl" .spec }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: gangplank-svc
                port:
                  name: http
{{- template "ingressTlsAuth" (dict "module" "auth" "package" "gangplank" "prefix" "gangplank." "spec" .spec) }}
{{- end }}
