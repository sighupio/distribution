
{{- if eq .spec.distribution.common.provider.type "none" "immutable" }}
{{- if and (hasKeyAny .spec "kubernetes") (hasKeyAny .spec.kubernetes "loadBalancers") }}
{{- if .spec.kubernetes.loadBalancers.enabled }}
---
apiVersion: monitoring.coreos.com/v1alpha1
kind: ScrapeConfig
metadata:
  name: haproxy-lb
  namespace: monitoring
  labels:
    prometheus: k8s
spec:
  staticConfigs:
    - labels:
        job: prometheus
      targets:
        {{- range $lb := .spec.kubernetes.loadBalancers.hosts }}
        - {{ $lb.ip }}:8405
        {{- end }}
{{- end }}
{{- end }}
{{- end }}
