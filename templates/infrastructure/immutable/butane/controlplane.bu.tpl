{{- /* Template for control plane nodes */ -}}
{{- range .data.nodes }}
{{- if eq .Role "controlplane" }}
---
# yaml-language-server: $schema=https://relativ-it.github.io/Butane-Schemas/Butane-Schema.json
# =============================================================================
# BUTANE TEMPLATE - Control Plane Node: {{ .Hostname }}
# =============================================================================
# This template is rendered by furyctl from fury-distribution
# =============================================================================
variant: flatcar
version: 1.1.0

passwd:
  users:
    - name: {{ .SSHUser }}
      ssh_authorized_keys:
{{- range .SSHKeys }}
        - {{ . }}
{{- end }}
      groups:
        - sudo
        - docker

storage:
  files:
    - path: /etc/hostname
      mode: 0644
      overwrite: true
      contents:
        inline: {{ .Hostname }}

    - path: /etc/hosts
      overwrite: false
      append:
        - inline: |
            {{ .IP }}   {{ .Hostname }}

    - path: /etc/systemd/network/10-static.network
      mode: 0644
      contents:
        inline: |
          [Match]
          Name=eth0

          [Network]
          Address={{ .IP }}/{{ .Netmask }}
          Gateway={{ .Gateway }}
          DNS={{ .DNS }}

    # =========================================================================
    # Sysext: Containerd
    # =========================================================================
    - path: /opt/extensions/containerd/containerd-2.1.4-x86-64.raw
      mode: 0644
      contents:
        source: {{ $.data.ipxeServerURL }}/assets/extensions/containerd-2.1.4-x86-64.raw

    - path: /etc/sysupdate.containerd.d/containerd.conf
      contents:
        source: {{ $.data.ipxeServerURL }}/assets/extensions/containerd.conf

  links:
    # Disable Docker from Flatcar base OS
    - path: /etc/extensions/docker-flatcar.raw
      target: /dev/null
      overwrite: true

    # Disable containerd from Flatcar base OS
    - path: /etc/extensions/containerd-flatcar.raw
      target: /dev/null
      overwrite: true

    # Enable containerd sysext
    - path: /etc/extensions/containerd.raw
      target: /opt/extensions/containerd/containerd-2.1.4-x86-64.raw
      hard: false

systemd:
  units:
    - name: systemd-sysupdate.timer
      enabled: true

    - name: systemd-sysupdate.service
      dropins:
        - name: containerd.conf
          contents: |
            [Service]
            ExecStartPre=/usr/bin/sh -c "readlink --canonicalize /etc/extensions/containerd.raw > /tmp/containerd"
            ExecStartPre=/usr/lib/systemd/systemd-sysupdate -C containerd update
            ExecStartPost=/usr/bin/sh -c "readlink --canonicalize /etc/extensions/containerd.raw > /tmp/containerd-new"
            ExecStartPost=/usr/bin/sh -c "if ! cmp --silent /tmp/containerd /tmp/containerd-new; then touch /run/reboot-required; fi"

    - name: containerd.service
      dropins:
        - name: 00-config-path.conf
          contents: |
            [Service]
            ExecStartPre=/bin/bash -c 'set -e; mkdir -p /etc/containerd/; if ! [ -e /etc/containerd/config.toml ]; then containerd config default > /etc/containerd/config.toml; fi'
            Environment="CONTAINERD_CONFIG=/etc/containerd/config.toml"
{{- end }}
{{- end }}
