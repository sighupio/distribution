{{- $lbEnabled := false }}
{{- $lbHosts := list }}
{{- if (.spec | digAny "kubernetes" "loadBalancers" "enabled" false) }}
  {{- $lbEnabled = true }}
  {{- range .spec.kubernetes.loadBalancers.hosts }}
  {{- $lbHosts = append $lbHosts .ip }}
  {{- end }}
{{- end }}
{{- if gt (.spec | digAny  "infrastructure" "loadBalancers" "members" list | len) 0 }}
  {{- $lbEnabled = true }}
  {{- range .spec.infrastructure.loadBalancers.members }}
  {{- $lbHosts = append $lbHosts .hostname }}
  {{- end }}
{{- end }}
{{- if $lbEnabled }}
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
        {{- range $lbHosts }}
        - {{ . }}:8405
        {{- end }}
{{- end }}
