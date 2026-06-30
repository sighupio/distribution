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
    # furyctl copies admin.conf into this work dir only in the later core phase, so a clean upgrade run (no
    # leftover from a prior apply, e.g. after rm -rf .furyctl or without --skip-deps-download) has no
    # kubeconfig for the localhost-delegated kubectl checks. Fetch it from a control plane up front; 54, 55
    # and 56 share this work dir, so the health gate, drain and uncordon all find ./admin.conf.
    - name: Fetch admin.conf to the controller for the upgrade run
      run_once: true
      ansible.builtin.fetch:
        src: /etc/kubernetes/admin.conf
        dest: ./admin.conf
        flat: true
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
