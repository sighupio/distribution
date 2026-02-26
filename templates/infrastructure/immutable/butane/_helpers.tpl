{{- define "passwd" }}
passwd:
  users:
    - name: {{ .SSHUser }}
      ssh_authorized_keys:
        - {{ .SSHPublicKey | quote }}
      groups:
        - sudo
  {{- if hasKeyAny .node "passwd" }}
    {{- if hasKeyAny .node.passwd "users" }}
{{ .node.passwd.users | toYaml | indent 4 }}
    {{- end }}
    {{- if hasKeyAny .node.passwd "groups" }}
  groups:
{{ .node.passwd.groups | toYaml | indent 4 }}
    {{- end }}
  {{- end }}
{{- end }}

{{- define  "hostname"}}
    - path: /etc/hostname
      mode: 0644
      overwrite: true
      contents:
        inline: {{ .node.hostname }}
{{- end }}

{{- define  "python"}}
    # Enable bundled Python sysext needed by Ansible
    - path: /etc/flatcar/enabled-sysext.conf
      mode: 0644
      contents:
        inline: |
          python
{{- end }}

{{- define "sysupdate-noop"}}
    # This dummy sysupdate configuration is needed to prevent spurious error messages
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
{{- end }}

{{- define "network" }}
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

{{- define "containerd-sysext-files" }}
    # containerd sysext download and sysupdate configuration
    - path: /opt/extensions/containerd/containerd-{{ .sysext.containerd.version }}-{{ .node.arch }}.raw
      mode: 0644
      contents:
        source: {{ .ipxeServerURL }}/assets/extensions/containerd-{{ .sysext.containerd.version }}-{{ .node.arch }}.raw
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
{{- end }}

{{- define "containerd-sysext-links" }}
    # Enable containerd sysext
    - path: /etc/extensions/containerd.raw
      target: /opt/extensions/containerd/containerd-{{ .sysext.containerd.version }}-{{ .node.arch }}.raw
      hard: false
{{- end }}

{{- define "containerd-sysext-sysupdate-dropin" }}
        - name: containerd.conf
          contents: |
            [Service]
            ExecStartPre=/usr/bin/sh -c "readlink --canonicalize /etc/extensions/containerd.raw > /tmp/containerd"
            ExecStartPre=/usr/lib/systemd/systemd-sysupdate -C containerd update
            ExecStartPost=/usr/bin/sh -c "readlink --canonicalize /etc/extensions/containerd.raw > /tmp/containerd-new"
            ExecStartPost=/usr/bin/sh -c "if ! cmp --silent /tmp/containerd /tmp/containerd-new; then touch /run/reboot-required; fi"
{{- end }}

{{- define "containerd-unit-generate-config"}}
    - name: containerd.service
      dropins:
        - name: 00-config-path.conf
          contents: |
            [Service]
            ExecStartPre=/bin/bash -c 'set -e; mkdir -p /etc/containerd/; if ! [ -e /etc/containerd/config.toml ]; then containerd config default > /etc/containerd/config.toml; fi'
            Environment="CONTAINERD_CONFIG=/etc/containerd/config.toml"
{{- end }}

{{- define "keepalived-sysext-files" }}
    # keepalived sysext download and sysupdate configuration
    - path: /opt/extensions/keepalived/keepalived-{{ .sysext.keepalived.version }}-{{ .node.arch }}.raw
      mode: 0644
      contents:
        source: {{ .ipxeServerURL }}/assets/extensions/keepalived-{{ .sysext.keepalived.version }}-{{ .node.arch }}.raw
    - path: /etc/sysupdate.keepalived.d/keepalived.conf
      contents:
        inline: |
          [Transfer]
          ProtectVersion=%A

          [Source]
          Type=regular-file
          Path=/opt/extensions/keepalived
          MatchPattern=keepalived-@v-@u.raw

          [Target]
          Type=regular-file
          Path=/etc/extensions
          MatchPattern=keepalived-@v
          CurrentSymlink=/etc/extensions/keepalived.raw
{{- end }}

{{- define "keepalived-sysext-links" }}
    # Enable keepalived sysext
    - path: /etc/extensions/keepalived.raw
      target: /opt/extensions/keepalived/keepalived-{{ .sysext.keepalived.version }}-{{ .node.arch }}.raw
      hard: false
{{- end }}

{{- define "keepalived-sysext-sysupdate-dropin" }}
        - name: keepalived.conf
          contents: |
            [Service]
            ExecStartPre=/usr/bin/sh -c "readlink --canonicalize /etc/extensions/keepalived.raw > /tmp/keepalived"
            ExecStartPre=/usr/lib/systemd/systemd-sysupdate -C keepalived update
            ExecStartPost=/usr/bin/sh -c "readlink --canonicalize /etc/extensions/keepalived.raw > /tmp/keepalived-new"
            ExecStartPost=/usr/bin/sh -c "if ! cmp --silent /tmp/keepalived /tmp/keepalived-new; then touch /run/reboot-required; fi"
{{- end }}

{{- define "keepalived-unit-fix-binary-path"}}
    # =========================================================================
    # Keepalived service - Fix binary path
    # This issue is present only on LTS, on stable /usr/sbin is linked to /usr/bin
    # =========================================================================
    - name: keepalived.service
      enabled: true
      dropins:
        - name: 20-fix-binary-path.conf
          contents: |
            [Service]
            ExecStart=
            ExecStart=/usr/bin/keepalived --use-file /etc/keepalived/keepalived.conf $KEEPALIVED_OPTIONS
{{- end }}

{{- define "kubernetes-sysext-files" }}
    # kubernetes sysext download and sysupdate configuration
    - path: /opt/extensions/kubernetes/kubernetes-{{ .sysext.kubernetes.version }}-{{ .node.arch }}.raw
      mode: 0644
      contents:
        source: {{ .ipxeServerURL }}/assets/extensions/kubernetes-{{ .sysext.kubernetes.version }}-{{ .node.arch }}.raw
    - path: /etc/sysupdate.kubernetes.d/kubernetes.conf
      contents:
        inline: |
          [Transfer]
          ProtectVersion=%A

          [Source]
          Type=regular-file
          Path=/opt/extensions/kubernetes
          MatchPattern=kubernetes-@v-@u.raw

          [Target]
          Type=regular-file
          Path=/etc/extensions
          MatchPattern=kubernetes-@v
          CurrentSymlink=/etc/extensions/kubernetes.raw
{{- end }}

{{- define "kubernetes-sysext-links" }}
    # Enable kubernetes sysext
    - path: /etc/extensions/kubernetes.raw
      target: /opt/extensions/kubernetes/kubernetes-{{ .sysext.kubernetes.version }}-{{ .node.arch }}.raw
      hard: false
{{- end }}

{{- define "kubernetes-sysext-sysupdate-dropin" }}
        - name: kubernetes.conf
          contents: |
            [Service]
            ExecStartPre=/usr/bin/sh -c "readlink --canonicalize /etc/extensions/kubernetes.raw > /tmp/kubernetes"
            ExecStartPre=/usr/lib/systemd/systemd-sysupdate -C kubernetes update
            ExecStartPost=/usr/bin/sh -c "readlink --canonicalize /etc/extensions/kubernetes.raw > /tmp/kubernetes-new"
            ExecStartPost=/usr/bin/sh -c "if ! cmp --silent /tmp/kubernetes /tmp/kubernetes-new; then touch /run/reboot-required; fi"
{{- end }}

{{- define "etcd-sysext-files" }}
    # etcd sysext download and sysupdate configuration
    - path: /opt/extensions/etcd/etcd-{{ .sysext.etcd.version }}-{{ .node.arch }}.raw
      mode: 0644
      contents:
        source: {{ .ipxeServerURL }}/assets/extensions/etcd-{{ .sysext.etcd.version }}-{{ .node.arch }}.raw
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
{{- end }}

{{- define "etcd-sysext-links" }}
    # Enable etcd sysext
    - path: /etc/extensions/etcd.raw
      target: /opt/extensions/etcd/etcd-{{ .sysext.etcd.version }}-{{ .node.arch }}.raw
      hard: false
{{- end }}

{{- define "etcd-sysext-sysupdate-dropin" }}
        - name: etcd.conf
          contents: |
            [Service]
            ExecStartPre=/usr/bin/sh -c "readlink --canonicalize /etc/extensions/etcd.raw > /tmp/etcd"
            ExecStartPre=/usr/lib/systemd/systemd-sysupdate -C etcd update
            ExecStartPost=/usr/bin/sh -c "readlink --canonicalize /etc/extensions/etcd.raw > /tmp/etcd-new"
            ExecStartPost=/usr/bin/sh -c "if ! cmp --silent /tmp/etcd /tmp/etcd-new; then touch /run/reboot-required; fi"
{{- end }}

{{- define "disable-flatcar-containerd-docker" }}
    # Disable Docker from Flatcar base OS
    - path: /etc/extensions/docker-flatcar.raw
      target: /dev/null
      overwrite: true
    # Disable containerd from Flatcar base OS
    - path: /etc/extensions/containerd-flatcar.raw
      target: /dev/null
      overwrite: true
{{- end }}

{{- define "locksmith-disable" }}
    - name: locksmithd.service
      # Disable Flatcar native reboot coordination as KureD will handle OS updates, too
      mask: true
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