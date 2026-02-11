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