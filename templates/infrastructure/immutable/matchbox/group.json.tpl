{{- /* Template for Matchbox groups (MAC address mapping) */ -}}
{{- range .data.nodes }}
---
{
  "id": "{{ .Hostname }}",
  "name": "{{ .Hostname }}",
  "profile": "{{ .Hostname }}",
  "selector": {
    "mac": "{{ .MAC }}"
  },
  "metadata": {
    "hostname": "{{ .Hostname }}",
    "ip_address": "{{ .IP }}",
    "role": "{{ .Role }}"
  }
}
{{- end }}
