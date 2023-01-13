---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    forecastle.stakater.com/expose: "true"
    forecastle.stakater.com/appName: "Forecastle"
    forecastle.stakater.com/icon: "https://raw.githubusercontent.com/stakater/Forecastle/master/assets/web/forecastle-round-100px.png"
    {{ if not .spec.distribution.modules.ingress.overrides.ingresses.forecastle.disableAuth }}{{ template "ingressAuth" . }}{{ end }}
    {{ template "certManagerClusterIssuer" . }}
  name: forecastle
  {{ if and (not .spec.distribution.modules.policy.overrides.ingresses.gpm.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
  namespace: pomerium
  {{ else }}
  namespace: ingress-nginx
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
          {{ if and (not .spec.distribution.modules.policy.overrides.ingresses.gpm.disableAuth) (eq .spec.distribution.modules.auth.provider.type "sso") }}
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
