variant: flatcar
version: 1.1.0

passwd:
  users:
    - name: {{ .sshUsername }}
      groups:
        - sudo
      ssh_authorized_keys:
        - {{ .sshPublicKey }}

storage:
  files:
    - path: /etc/hostname
      mode: 0644
      overwrite: true
      contents:
        inline: {{ .hostname }}

    - path: /opt/ignition/config.ign
      mode: 0644
      overwrite: true
      contents:
        compression: gzip
        source: data:;base64,{{ .base64EncodedIgnition }}

    - path: /etc/issue
      overwrite: true
      contents:
        inline: |
           ╭───────────────────────────────────────────────────────╮
           │                                                       │
           │                      PLEASE WAIT                      │
           │  FLATCAR WILL BE INSTALLED TO DISK AND THEN REBOOTED  │
           │                                                       │
           ╰───────────────────────────────────────────────────────╯

systemd:
  units:
    - name: flatcar-install-blocked.service
      enabled: true
      contents: |
        [Unit]
        Description=Install Flatcar to disk blocked
        Requires=network-online.target
        After=network-online.target
        ConditionPathExists=/opt/ignition/config.ign
        ConditionPathExists=/dev/disk/by-label/ROOT

        [Service]
        Type=oneshot
        ExecStart=/usr/bin/curl --retry 2 --retry-connrefused --connect-timeout 5 --max-time 15 --retry-max-time 40 -X POST '{{ .ipxeServerURL }}/status?node={{ .hostname }}&status=installation-blocked'
        RemainAfterExit=yes

        [Install]
        WantedBy=multi-user.target
    - name: flatcar-install.service
      enabled: true
      contents: |
        [Unit]
        Description=Install Flatcar to disk
        Requires=network-online.target
        After=network-online.target
        ConditionPathExists=/opt/ignition/config.ign
        ConditionPathExists=!/dev/disk/by-label/ROOT

        [Service]
        Type=oneshot
        {{- if .ipxeServerPreInstallCommands }}
        ExecStartPre=/usr/bin/curl --retry 2 --retry-connrefused --connect-timeout 5 --max-time 15 --retry-max-time 40 -X POST '{{ .ipxeServerURL }}/status?node={{ .hostname }}&status=running%%20pre-install%%20commands'
        {{- range .ipxeServerPreInstallCommands }}
        ExecStartPre={{ . }}
        {{- end }}
        {{- end }}
        ExecStartPre=/usr/bin/curl --retry 2 --retry-connrefused --connect-timeout 5 --max-time 15 --retry-max-time 40 -X POST '{{ .ipxeServerURL }}/status?node={{ .hostname }}&status=installing'
        ExecStart=/usr/bin/flatcar-install -d {{ .installDisk }} -i /opt/ignition/config.ign -b {{ .ipxeServerURL }}/assets/flatcar/{{ .arch }}
        {{- if .ipxeServerPostInstallCommands }}
        ExecStartPost=/usr/bin/curl --retry 2 --retry-connrefused --connect-timeout 5 --max-time 15 --retry-max-time 40 -X POST '{{ .ipxeServerURL }}/status?node={{ .hostname }}&status=running%%20post-install%%20commands'
        {{- range .ipxeServerPostInstallCommands }}
        ExecStartPost={{ . }}
        {{- end }}
        {{- end }}
        ExecStartPost=/usr/bin/curl --retry 2 --retry-connrefused --connect-timeout 5 --max-time 15 --retry-max-time 40 -X POST '{{ .ipxeServerURL }}/status?node={{ .hostname }}&status=rebooting'
        ExecStartPost=/usr/bin/systemctl --no-block reboot
        RemainAfterExit=yes

        [Install]
        WantedBy=multi-user.target
