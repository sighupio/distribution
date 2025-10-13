{{- $fluentdReplicas := index .spec.distribution.modules.logging.operator.fluentd "replicas" }}
{{- $fluentdResources := index .spec.distribution.modules.logging.operator.fluentd "resources" }}
{{- $fluentbitResources := index .spec.distribution.modules.logging.operator.fluentbit "resources" }}

{{- if or $fluentdReplicas $fluentdResources }}
---
apiVersion: logging.banzaicloud.io/v1beta1
kind: Logging
metadata:
  name: infra
spec:
  fluentd:
    {{- if $fluentdReplicas }}
    scaling:
      replicas: {{ $fluentdReplicas }}
    {{- end }}
    {{- if $fluentdResources }}
    resources:
{{ $fluentdResources | toYaml | indent 6 }}
    {{- end }}
{{- end }}

{{- if $fluentbitResources }}
---
apiVersion: logging.banzaicloud.io/v1beta1
kind: FluentbitAgent
metadata:
  name: infra
spec:
  resources:
{{ $fluentbitResources | toYaml | indent 6 }}
{{- end }}