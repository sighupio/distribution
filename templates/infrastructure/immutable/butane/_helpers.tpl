{{- define "networkdConfig" }}
{{- range $name, $iface := .node.network.ethernets }}
    - path: /etc/systemd/network/10-{{ $name }}.network
      mode: 0644
      contents:
        inline: |
          [Match]
          Name={{ $name }}
          [Network]
          {{- if index $iface "dhcp4" }}
          DHCP=ipv4
          {{- else }}
          {{- range $iface.addresses }}
          Address={{ . }}
          {{- end }}
          {{- if index $iface "gateway" }}
          Gateway={{ $iface.gateway }}
          {{- end }}
          {{- range ($iface | digAny "nameservers" "addresses" list) }}
          DNS={{ . }}
          {{- end }}
          {{- end }}
          {{- if hasKeyAny $iface "routes" }}
          {{- range $iface.routes }}
          [Route]
          Destination={{ .to }}
          Gateway={{ .via }}
          {{- end }}
          {{- end }}
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