# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.
{{- $etcdOnControlPlane := true }}
{{- if gt ( .spec.kubernetes | digAny "etcd" "members" list | len ) 0 }}
  {{- $etcdOnControlPlane = false }}
{{- end }}
---
# etcd upgrade: align the etcd sysext + renew certificates (in-band, no drain/reboot).
- name: Upgrade etcd
  hosts: {{ if $etcdOnControlPlane }}control_plane{{ else }}etcd{{ end }}
  serial: 1
  become: true
  vars:
    etcd_upgrade: true
  roles:
    - etcd
  tags:
    - etcd
