# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.
{{- $etcdOnControlPlane := true }}
{{- if gt ( .spec.kubernetes | digAny "etcd" "members" list | len ) 0 }}
  {{- $etcdOnControlPlane = false }}
{{- end }}
---
# etcd upgrade: align the etcd sysext + renew certs; stacked etcd rides the control-plane reboot, dedicated etcd stages+reboots the OS here (serial:1, quorum-guarded, snapshot first).
- name: Upgrade etcd
  hosts: {{ if $etcdOnControlPlane }}control_plane{{ else }}etcd{{ end }}
  serial: 1
  become: true
  vars:
    etcd_upgrade: true
{{- if not $etcdOnControlPlane }}
    # Dedicated etcd nodes never ride a control-plane reboot, so reboot them here to apply the staged OS + etcd extension.
    os_update_reboot: true
{{- end }}
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
{{- if not $etcdOnControlPlane }}
    # Stage the OS on the dedicated etcd node (async, no kubectl drain — etcd is not a Kubernetes node); the reboot below activates it.
    - name: Stage the operating system update on the etcd node
      ansible.builtin.include_role:
        name: os-upgrade
        tasks_from: os_stage.yml
{{- end }}
  roles:
    - etcd
{{- if not $etcdOnControlPlane }}
  post_tasks:
    # Snapshot etcd + assert quorum, then reboot to activate the staged OS and etcd extension, then confirm it rejoined.
    - name: Snapshot etcd and guard quorum before the reboot
      ansible.builtin.include_role:
        name: etcd
        tasks_from: pre_reboot.yml
    - name: Reboot the etcd node to activate the staged OS and etcd extension
      ansible.builtin.include_role:
        name: os-upgrade
        tasks_from: os_reboot.yml
    - name: Confirm etcd rejoined and the cluster is healthy after the reboot
      ansible.builtin.include_role:
        name: etcd
        tasks_from: post_reboot.yml
{{- end }}
  tags:
    - etcd
