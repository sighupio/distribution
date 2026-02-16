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
    - path: /opt/ignition/config.ign
      mode: 0644
      overwrite: true
      contents:
        compression: gzip
        source: data:;base64,{{ .base64EncodedIgnition }}

systemd:
  units:
    - name: furyctl-status-reporter.service
      enabled: true
      contents: |
        [Unit]
        Description=Report node status to furyctl
        Requires=network-online.target
        After=network-online.target
        [Service]
        Type=oneshot
        ExecStart=/usr/bin/curl '{{ .ipxeServerURL }}/status?node={{ .hostname }}&status=installing'
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
        ExecStart=/usr/bin/flatcar-install -d {{ .installDisk }} -i /opt/ignition/config.ign
        ExecStartPost=/usr/bin/systemctl --no-block reboot
        RemainAfterExit=yes

        [Install]
        WantedBy=multi-user.target
