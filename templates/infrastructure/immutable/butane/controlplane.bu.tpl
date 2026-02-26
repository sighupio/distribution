{{- if eq .data.role "controlplane" -}}
{{- with .data -}}
---
# yaml-language-server: $schema=https://relativ-it.github.io/Butane-Schemas/Butane-Schema.json
variant: flatcar
version: 1.1.0

{{ template "passwd" . }}

storage:
  files:
{{ template "hostname" . }}
{{ template "network" . }}
{{ template "python" . }}
{{ template "sysupdate-noop" . }}
{{ template "containerd-sysext-files" . }}
{{ template "keepalived-sysext-files" . }}
{{ template "kubernetes-sysext-files" . }}
{{ template "etcd-sysext-files" . }}
    # User-provided additional files
{{- if hasKeyAny .node.storage "files" }}
{{ .node.storage.files | toYaml | indent 4 }}
{{- end }}

  links:
    # Disable Flatcar's built-in containerd and docker by symlinking them to /dev/null
{{ template "disable-flatcar-containerd-docker"}}

    # Enable custom sysexts
{{ template "containerd-sysext-links" . }}
{{ template "keepalived-sysext-links" . }}
{{ template "kubernetes-sysext-links" . }}
{{ template "etcd-sysext-links" . }}
    # User-provided additional links
{{- if hasKeyAny .node.storage "links" }}
{{ .node.storage.links | toYaml | indent 4 }}
{{- end }}

systemd:
  units:
    # Enable sysupdate timer to check for updates and trigger them if needed
    - name: systemd-sysupdate.timer
      enabled: true
    # Disable Flatcar native reboot coordination as KureD will handle OS updates, too
    - name: locksmithd.service
      mask: true
    # Sysupdate drop-ins for our custom sysexts, to trigger updates when new versions are available and reboot if needed
    - name: systemd-sysupdate.service
      dropins:
{{ template "containerd-sysext-sysupdate-dropin" . }}
{{ template "keepalived-sysext-sysupdate-dropin" . }}
{{ template "kubernetes-sysext-sysupdate-dropin" . }}
{{ template "etcd-sysext-sysupdate-dropin" . }}
    # Other needed units
{{ template "keepalived-unit-fix-binary-path" . }}
{{ template "containerd-unit-generate-config" . }}
{{ template "statusReporterBooted" . }}
    # User-provided units
{{- if (.node | digAny "systemd" "units" false) }}
{{ .node.systemd.units | toYaml | indent 4 }}
{{- end }}

{{- end }}
{{- else }}
{{ fail "Attempting to apply control plane configuration to a non-control plane node" }}
{{- end }}
