{{- if eq .data.role "etcd" -}}
{{- with .data -}}
---
# yaml-language-server: $schema=https://relativ-it.github.io/Butane-Schemas/Butane-Schema.json
variant: flatcar
version: 1.1.0

passwd:
  users:
    - name: {{ .SSHUser }}
      ssh_authorized_keys:
        - {{ .SSHPublicKey | quote }}
      groups:
        - sudo

storage:
  files:
    - path: /etc/hostname
      mode: 0644
      overwrite: true
      contents:
        inline: {{ .node.hostname }}

{{- template "networkdConfig" . }}

    # Enable bundled Python sysext needed by Ansible
    - path: /etc/flatcar/enabled-sysext.conf
      mode: 0644
      contents:
        inline: |
          python

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
    - path: /opt/extensions/containerd/containerd-{{ $.data.sysext.containerd.version }}-{{ .node.arch }}.raw
      mode: 0644
      contents:
        source: {{ $.data.ipxeServerURL }}/assets/extensions/containerd-{{ $.data.sysext.containerd.version }}-{{ .node.arch }}.raw
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
    - path: /opt/extensions/etcd/etcd-{{ $.data.sysext.etcd.version }}-{{ .node.arch }}.raw
      mode: 0644
      contents:
        source: {{ $.data.ipxeServerURL }}/assets/extensions/etcd-{{ $.data.sysext.etcd.version }}-{{ .node.arch }}.raw

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

    # kubeadm - needed for configuring etcd
    - path: /opt/extensions/kubeadm/kubeadm-{{ $.data.sysext.kubeadm.version }}-{{ .node.arch }}.raw
      contents:
        source: {{ $.data.ipxeServerURL }}/assets/extensions/kubeadm-{{ $.data.sysext.kubeadm.version }}-{{ .node.arch }}.raw

{{- if hasKeyAny .node.storage "files" }}
{{ .node.storage.files | toYaml | indent 4 }}
{{- end }}

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
      target: /opt/extensions/containerd/containerd-{{ $.data.sysext.containerd.version }}-{{ .node.arch }}.raw
      hard: false

    # Enable etcd sysext
    - path: /etc/extensions/etcd.raw
      target: /opt/extensions/etcd/etcd-{{ $.data.sysext.etcd.version }}-{{ .node.arch }}.raw
      hard: false
    # Kubeadm
    - target: /opt/extensions/kubeadm/kubeadm-{{ $.data.sysext.kubeadm.version }}-{{ .node.arch }}.raw
      path: /etc/extensions/kubeadm.raw
      hard: false

{{- if hasKeyAny .node.storage "links" }}
{{ .node.storage.links | toYaml | indent 4 }}
{{- end }}

systemd:
  units:
    # TODO: should we disable locksmithd too?
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
    # TODO: in my butanes I'm also masking etcd.service so it does not start
    # automatically before configuring it.
    # Should we do it here too?
{{ template "statusReporterBooted" . }}
{{- if (.node | digAny "systemd" "units" false) }}
{{ .node.systemd.units | toYaml | indent 4 }}
{{- end }}

{{- end }}
{{- else }}
{{ fail "Attempting to apply control plane configuration to a non-control plane node" }}
{{- end }}
