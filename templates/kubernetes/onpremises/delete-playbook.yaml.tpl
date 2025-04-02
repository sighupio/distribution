# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

- name: Reset Kubernetes nodes
  hosts: master,nodes
  become: true
  tasks:
    - name: Run kubeadm reset
      shell: kubeadm reset -f
    - name: Clean iptables
      shell: "iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X"
    - name: Clean IPVS
      shell: "ipvsadm --clear"
    - name: Clean CNI dir
      file:
        path: /etc/cni/net.d
        state: absent
  tags:
    - reset-k8s

- name: Reset etcd nodes
  hosts: master,etcd
  become: true
  tasks:
    - name: Stop etcd
      systemd:
        name: etcd
        state: stopped
      when: inventory_hostname in groups['etcd']
    - name: Clean etcd datadir
      file:
        path: /var/lib/etcd
        state: absent
    - name: Cleanup pki etcd
      file:
        path: /etc/etcd/pki
        state: absent
    - name: Cleanup pki kubernetes
      file:
        path: /etc/kubernetes/pki
        state: absent
  tags:
    - reset-etcd-nodes

- name: Reboot
  hosts: master,nodes,etcd
  become: true
  tasks:   
    - name: Reboot
      reboot:
  tags:
    - reboot