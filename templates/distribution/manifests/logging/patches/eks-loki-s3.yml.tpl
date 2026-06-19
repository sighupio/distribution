{{- if and (eq .spec.distribution.modules.logging.loki.backend "s3") (eq .spec.distribution.common.provider.type "eks") }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: {{ .spec.distribution.modules.logging.loki.s3.iamRoleArn }}
  name: loki
  namespace: logging
{{- end }}
