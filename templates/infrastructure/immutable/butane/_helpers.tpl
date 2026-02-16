{{- define "networkdConfig" }}
{{- range $name, $iface := .node.network.ethernets }}
          [Match]
          Name={{ $name }}

          [Network]
          #FIXME This is probably not correct format for multiple addresses
          Address={{ $iface.addresses | join "," }}
          Gateway={{ $iface.gateway }}
          DNS={{ $iface.nameservers.addresses | join "," }}
{{- end }}
{{- end }}

{{- define "statusReporterBooted" }}
    - name: status-reporter.service
      enabled: true
      contents: |
        [Unit]
        Description=Report status to furyctl
        Requires=network-online.target
        After=network-online.target

        [Service]
        Type=oneshot
        ExecStart=/usr/bin/curl '{{ .ipxeServerURL }}/status?node={{ .node.hostname }}&status=booted'
        RemainAfterExit=yes

        [Install]
        WantedBy=multi-user.target

{{- end}}