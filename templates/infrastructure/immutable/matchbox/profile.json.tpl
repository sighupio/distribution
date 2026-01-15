{{- /* Template for Matchbox boot profiles */ -}}
{{- range .data.nodes }}
---
{
  "id": "{{ .Hostname }}",
  "name": "{{ .Hostname }}",
  "boot": {
    "kernel": "{{ .FlatcarKernelURL }}",
    "initrd": ["{{ .FlatcarInitrdURL }}"],
    "args": [
      "flatcar.first_boot=1",
      "ignition.config.url={{ $.data.ipxeServerURL }}/ignition?mac=${mac:hexhyp}",
      "console=ttyS0,115200n8",
      "console=tty0"
    ]
  },
  "ignition_id": "{{ .Hostname }}.ign"
}
{{- end }}
