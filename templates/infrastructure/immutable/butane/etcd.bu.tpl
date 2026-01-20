{{- /* Template for dedicated etcd nodes */ -}}
{{- range .data.nodes }}
{{- if eq .Role "etcd" }}
---
# yaml-language-server: $schema=https://relativ-it.github.io/Butane-Schemas/Butane-Schema.json
# =============================================================================
# BUTANE TEMPLATE - etcd Node: {{ .Hostname }}
# =============================================================================
# This template is rendered by furyctl from fury-distribution
# Architecture: {{ .Arch }}
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
    # Sysext: Common noop
    # =========================================================================
    - path: /etc/sysupdate.d/noop.conf
      contents:
        inline: |
          [Source]
          Type=regular-file
          Path=/
          MatchPattern=invalid@v.raw
          [Target]
          Type=regular-file
          Path=/

    # =========================================================================
    # Sysext: Containerd
    # =========================================================================
    - path: /opt/extensions/containerd/containerd-{{ $.data.sysext.containerd.version }}-{{ .Arch }}.raw
      mode: 0644
      contents:
        source: {{ $.data.ipxeServerURL }}/assets/extensions/containerd-{{ $.data.sysext.containerd.version }}-{{ .Arch }}.raw

    - path: /etc/sysupdate.containerd.d/containerd.conf
      contents:
        inline: |
          [Transfer]
          ProtectVersion=%A

          [Source]
          Type=regular-file
          Path=/opt/extensions/containerd
          MatchPattern=containerd-@v-@u.raw

          [Target]
          Type=regular-file
          Path=/etc/extensions
          MatchPattern=containerd-@v
          CurrentSymlink=/etc/extensions/containerd.raw

    # =========================================================================
    # Sysext: etcd
    # =========================================================================
    - path: /opt/extensions/etcd/etcd-{{ $.data.sysext.etcd.version }}-{{ .Arch }}.raw
      mode: 0644
      contents:
        source: {{ $.data.ipxeServerURL }}/assets/extensions/etcd-{{ $.data.sysext.etcd.version }}-{{ .Arch }}.raw

    - path: /etc/sysupdate.etcd.d/etcd.conf
      contents:
        inline: |
          [Transfer]
          ProtectVersion=%A

          [Source]
          Type=regular-file
          Path=/opt/extensions/etcd
          MatchPattern=etcd-@v-@u.raw

          [Target]
          Type=regular-file
          Path=/etc/extensions
          MatchPattern=etcd-@v
          CurrentSymlink=/etc/extensions/etcd.raw

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
      target: /opt/extensions/containerd/containerd-{{ $.data.sysext.containerd.version }}-{{ .Arch }}.raw
      hard: false

    # Enable etcd sysext
    - path: /etc/extensions/etcd.raw
      target: /opt/extensions/etcd/etcd-{{ $.data.sysext.etcd.version }}-{{ .Arch }}.raw
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

        - name: etcd.conf
          contents: |
            [Service]
            ExecStartPre=/usr/bin/sh -c "readlink --canonicalize /etc/extensions/etcd.raw > /tmp/etcd"
            ExecStartPre=/usr/lib/systemd/systemd-sysupdate -C etcd update
            ExecStartPost=/usr/bin/sh -c "readlink --canonicalize /etc/extensions/etcd.raw > /tmp/etcd-new"
            ExecStartPost=/usr/bin/sh -c "if ! cmp --silent /tmp/etcd /tmp/etcd-new; then touch /run/reboot-required; fi"

    - name: containerd.service
      dropins:
        - name: 00-config-path.conf
          contents: |
            [Service]
            ExecStartPre=/bin/bash -c 'set -e; mkdir -p /etc/containerd/; if ! [ -e /etc/containerd/config.toml ]; then containerd config default > /etc/containerd/config.toml; fi'
            Environment="CONTAINERD_CONFIG=/etc/containerd/config.toml"
{{- end }}
{{- end }}
