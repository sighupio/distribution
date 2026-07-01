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
  pre_tasks:
    # admin.conf lives only on control-planes; acquire it resiliently via the upgrade-gates role so dedicated etcd works too.
    - name: Acquire admin.conf for the controller-side kubectl checks
      run_once: true
      ansible.builtin.include_role:
        name: upgrade-gates
        tasks_from: fetch_admin_conf.yml
    # G1 (add-immutable-upgrade-gates): pre-upgrade cluster-health gate. run_once so it gates the whole run
    # — asserting all nodes Ready, the API reachable, no partial upgrade, and etcd healthy — BEFORE the
    # first node is touched. Aborts here rather than starting on an already-degraded cluster.
    - name: Gate the upgrade on overall cluster health
      run_once: true
      ansible.builtin.include_role:
        name: upgrade-gates
        tasks_from: cluster_health_gate.yml
  roles:
    - etcd
  tags:
    - etcd
