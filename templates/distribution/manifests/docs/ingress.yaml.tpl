---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sd-docs
  labels:
    app.kubernetes.io/name: docs
    app.kubernetes.io/version: "{{ .spec.distributionVersion }}"
    app.kubernetes.io/part-of: sighup-distribution
  annotations:
    cluster.kfd.sighup.io/useful-link.url: https://{{ template "docsUrl" .spec }}
    cluster.kfd.sighup.io/useful-link.name: "SD Documentation"
    forecastle.stakater.com/expose: "true"
    forecastle.stakater.com/appName: "SIGHUP Distribution Documentation"
    forecastle.stakater.com/icon: "https://raw.githubusercontent.com/sighupio/distribution/refs/heads/main/docs/assets/black-logo.png"
    {{ template "certManagerClusterIssuer" . }}
spec:
  ingressClassName:  {{ template "ingressClass" (dict "module" "docs" "package" "docs" "type" "internal" "spec" .spec) }}
  rules:
    - host: {{ template "docsUrl" .spec }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: sd-docs
                port:
                  name: http
{{- template "ingressTls" (dict "module" "docs" "package" "docs" "prefix" "docs." "spec" .spec) }}
