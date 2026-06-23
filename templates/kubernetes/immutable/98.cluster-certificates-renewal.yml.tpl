# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.
---
# Operator-invoked: renew ALL cluster certificates (kube + etcd) WITHOUT performing an upgrade.
# Use this to refresh certificates before they expire on a cluster that is not being upgraded.
# Run manually from the kubernetes workdir:  ansible-playbook 98.cluster-certificates-renewal.yml --become
# serial: 1 preserves etcd quorum and control-plane HA — one node at a time. Assumes etcd co-located on
# the control plane (the default immutable topology).
- name: Renew cluster certificates (kube + etcd)
  hosts: control_plane
  become: true
  serial: 1
  vars:
    etcd_certs_dir: /etc/etcd/pki
  tasks:
    - name: Set the backup timestamp
      ansible.builtin.set_fact:
        cert_backup_timestamp: "{{ "{{ lookup('pipe', 'date +%Y-%m-%d_%H-%M-%S') }}" }}"

    - name: Ensure the certificate backup directories exist
      ansible.builtin.file:
        path: "{{ "{{ ansible_env.HOME }}/certs-backup/{{ cert_backup_timestamp }}/{{ item }}" }}"
        state: directory
        mode: "0750"
      loop:
        - etc-kubernetes-pki
        - etc-etcd-pki

    - name: Back up the current Kubernetes and etcd certificates
      ansible.builtin.copy:
        src: "{{ "{{ item.src }}" }}"
        dest: "{{ "{{ ansible_env.HOME }}/certs-backup/{{ cert_backup_timestamp }}/{{ item.dest }}" }}"
        remote_src: true
        mode: preserve
        directory_mode: "0750"
      loop:
        - src: /etc/kubernetes/pki/
          dest: etc-kubernetes-pki
        - src: /etc/etcd/pki/
          dest: etc-etcd-pki

    - name: Renew the Kubernetes control-plane certificates
      ansible.builtin.command: "kubeadm certs renew {{ "{{ item }}" }}"
      loop:
        - super-admin.conf
        - admin.conf
        - apiserver
        - apiserver-kubelet-client
        - controller-manager.conf
        - front-proxy-client
        - scheduler.conf
      changed_when: true

    - name: Renew the etcd certificates
      ansible.builtin.command: "kubeadm certs renew --cert-dir=/etc/etcd/pki --config=/etc/etcd/kubeadm-etcd.yml {{ "{{ item }}" }}"
      loop:
        - apiserver-etcd-client
        - etcd-healthcheck-client
        - etcd-peer
        - etcd-server
      changed_when: true

    # Quorum-safe etcd restart (same guard + wait as the upgrade path): never stop a member while the
    # cluster is degraded, and wait for this member to rejoin before serial:1 advances.
    - name: Assert the etcd cluster is healthy before restarting this member
      ansible.builtin.command: etcdctl endpoint health --cluster
      environment:
        ETCDCTL_CACERT: "{{ "{{ etcd_certs_dir }}" }}/etcd/ca.crt"
        ETCDCTL_CERT: "{{ "{{ etcd_certs_dir }}" }}/apiserver-etcd-client.crt"
        ETCDCTL_KEY: "{{ "{{ etcd_certs_dir }}" }}/apiserver-etcd-client.key"
        ETCDCTL_DIAL_TIMEOUT: "3s"
      register: cert_etcd_health_pre
      changed_when: false

    - name: Restart etcd to load the renewed certificates
      ansible.builtin.systemd:
        name: etcd
        state: restarted

    - name: Wait for this etcd member to rejoin and the cluster to regain quorum
      ansible.builtin.command: etcdctl endpoint health --cluster
      environment:
        ETCDCTL_CACERT: "{{ "{{ etcd_certs_dir }}" }}/etcd/ca.crt"
        ETCDCTL_CERT: "{{ "{{ etcd_certs_dir }}" }}/apiserver-etcd-client.crt"
        ETCDCTL_KEY: "{{ "{{ etcd_certs_dir }}" }}/apiserver-etcd-client.key"
        ETCDCTL_DIAL_TIMEOUT: "3s"
      register: cert_etcd_health_post
      changed_when: false
      until: cert_etcd_health_post.rc == 0
      retries: 12
      delay: 5

    # Restart this node's control-plane static pods so they load the renewed certs (delete -> kubelet
    # recreates from the static manifests). serial:1 keeps the API up via the other control planes.
    - name: Restart the control-plane static pods to load the renewed certificates
      delegate_to: localhost
      become: false
      changed_when: true
      ansible.builtin.shell: "{{ .paths.kubectl }} {{ "delete pod -n kube-system -l tier=control-plane --field-selector spec.nodeName={{ inventory_hostname }} --kubeconfig={{ kubernetes_kubeconfig_path }}admin.conf" }}"
