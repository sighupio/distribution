
{{- /* Defaults */ -}}
{{- $apiHost := "" }}
{{- $apiPort := "" }}

{{- /* Calculate the API server endpoint from the Kubernetes control plane address when the kind is OnPremises. */ -}}
{{- if and (eq .spec.distribution.common.provider.type "none") (hasKeyAny .spec "kubernetes") }}
  {{- $apiAddress := split ":" .spec.kubernetes.controlPlaneAddress }}
  {{- $apiHost = $apiAddress._0 }}
  {{- if eq (len $apiAddress) 2 }}
  {{- $apiPort = $apiAddress._1}}
  {{- else }}
      {{- /* If no port is specified in the address we assume the default HTTPS port 443 */ -}}
      {{- $apiPort = "443" }}
  {{- end }}
  {{- if or (eq $apiHost "") (eq $apiPort "") }}
    {{- fail "Error while calculating the Kubernetes API endpoint host and port. Calculated values are API Host: '$apiHost' and API Port: '$apiPort'" }}
  {{- end }}
{{- end }}

kind: ConfigMap
apiVersion: v1
metadata:
  name: kubernetes-services-endpoint
  namespace: tigera-operator
data:
  KUBERNETES_SERVICE_HOST: "{{ $apiHost }}"
  KUBERNETES_SERVICE_PORT: "{{ $apiPort }}"