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
    - name: furyctl-status-reporter.service
      enabled: true
      contents: |
        [Unit]
        Description=Report node status to furyctl
        Requires=network-online.target
        After=network-online.target
        ConditionFirstBoot=yes

        [Service]
        Type=oneshot
        ExecStart=/usr/bin/curl -X POST '{{ .ipxeServerURL }}/status?node={{ .node.hostname }}&status=booted'
        RemainAfterExit=yes
        

        [Install]
        WantedBy=multi-user.target

{{- end}}