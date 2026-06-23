# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.
---
# Worker upgrade, serial 1: drain → roles (sysext + kubeadm upgrade node + OS reboot) → uncordon.
- name: Upgrade the worker nodes
  hosts: nodes
  serial: 1
  become: true
  vars:
    upgrade: true
  pre_tasks:
    - name: Cordon and drain the node
      delegate_to: localhost
      become: false
      changed_when: true
      ansible.builtin.shell: "{{ .paths.kubectl }} {{ "drain {{ inventory_hostname }} --grace-period=60 --timeout=360s --force --ignore-daemonsets --delete-emptydir-data --kubeconfig={{ kubernetes_kubeconfig_path }}admin.conf" }}"
  roles:
    - containerd
    - kube-worker
  post_tasks:
    - name: Uncordon the node
      delegate_to: localhost
      become: false
      changed_when: true
      ansible.builtin.shell: "sleep 60 && {{ .paths.kubectl }} {{ "uncordon {{ inventory_hostname }} --kubeconfig={{ kubernetes_kubeconfig_path }}admin.conf" }}"
{{- if ne .options.skipPodsRunningCheck true }}
    # Health gate scoped to the just-upgraded node (--field-selector spec.nodeName): unscheduled, benign
    # cluster-wide Pending pods have no nodeName and drop out, so a healthy node passes without --force,
    # while pods on THIS node that did not recover still fail the gate. The header keeps the count >= 1.
    - name: Wait for the upgraded node's pods to be running or completed
      delegate_to: localhost
      become: false
      changed_when: false
      ansible.builtin.shell: "{{ .paths.kubectl }} {{ "get pods -A -o wide --field-selector spec.nodeName={{ inventory_hostname }} --kubeconfig={{ kubernetes_kubeconfig_path }}admin.conf" }} | grep -cvE 'Running|Completed'"
      register: num_pods_result
      until: "num_pods_result.stdout | int < 2"
      retries: {{ .options.podRunningTimeout | default 10 }}
      delay: 30
{{- end }}
    # Re-gather facts: the role rebooted the node, so play-start facts are stale.
    - name: Refresh OS facts after the upgrade
      ansible.builtin.setup:
        gather_subset: min
    - name: Report the upgraded version
      ansible.builtin.debug:
        msg: "{{ "{{ inventory_hostname }} upgraded to Kubernetes {{ kubernetes_version }} / Flatcar {{ ansible_facts['distribution_version'] | default('unknown') }}" }}"
  tags:
    - kube-worker
