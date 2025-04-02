# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
- name: Control plane upgrade
  hosts: master
  serial: 1
  become: true
  vars:
    skip_kubelet_upgrade: true
    upgrade: true
  roles:
    - kube-node-common
    - kube-control-plane
  tags:
    - kubeadm-upgrade

- name: Kubelet and Containerd upgrade
  hosts: master
  serial: 1
  become: true
  vars:
    skip_kubelet_upgrade: false
  roles:
    - kube-node-common
    - containerd
  tags:
    - package-upgrade
