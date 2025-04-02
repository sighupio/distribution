# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
- name: Upgrade etcd
  hosts: master,etcd
  serial: 1
  become: true
  vars:
    etcd_address: "{{ "{{ ansible_host }}" }}"
    etcd_upgrade: true
  roles:
    - etcd
  tags:
    - etcd

- name: Kubeadm package upgrade on etcd nodes
  become: true
  hosts: etcd
  tasks:
    - name: Include kube-node-common role
      ansible.builtin.include_role:
        name: kube-node-common
      when: not etcd_on_control_plane
  tags:
    - kube-node-common
