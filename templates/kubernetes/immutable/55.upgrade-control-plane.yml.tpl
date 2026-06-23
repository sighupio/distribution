# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.
---
# Control-plane upgrade, serial 1. No drain here (mirrors on-prem 55); the role drains only around its OS reboot.
- name: Upgrade the control plane
  hosts: control_plane
  serial: 1
  become: true
  vars:
    upgrade: true
  roles:
    - containerd
    - kube-control-plane
  post_tasks:
    # Re-gather facts: the role rebooted the node, so play-start facts are stale.
    - name: Refresh OS facts after the upgrade
      ansible.builtin.setup:
        gather_subset: min
    - name: Report the upgraded version
      ansible.builtin.debug:
        msg: "{{ "{{ inventory_hostname }} upgraded to Kubernetes {{ kubernetes_version }} / Flatcar {{ ansible_facts['distribution_version'] | default('unknown') }}" }}"
  tags:
    - kubeadm-upgrade
