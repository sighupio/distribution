# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.


- name: Kubernetes node preparation
  become: true
  hosts: nodes
  vars:
    skip_kubelet_upgrade: True
  roles:
    - kube-node-common
  tags:
    - kube-node-common

- name: Kubernetes drain
  hosts: nodes
  tasks:
    - name: Get node name
      set_fact:
        node_name: "{{ print "{{ kubernetes_hostname }}" }}"
    - name: Drain node
      delegate_to: localhost
      shell: "{{ .paths.kubectl }} {{ print "drain --grace-period=60 --timeout=360s --force --ignore-daemonsets --delete-emptydir-data {{ node_name }} --kubeconfig={{ kubernetes_kubeconfig_path }}admin.conf" }}"

- name: Kubernetes kubeadm upgrade node
  become: true
  hosts: nodes
  tasks:
    - name: Upgrade kubelet config
      shell: "kubeadm upgrade node"

- name: Kubelet and Containerd upgrade
  become: true
  hosts: nodes
  vars:
    skip_kubelet_upgrade: False
  roles:
    - kube-node-common
    - containerd
    - kube-worker
  tags:
    - kube-node-common
    - containerd
    - kube-worker

- name: Kubernetes uncordon node
  hosts: nodes
  tasks:
    - name: Get node name
      set_fact:
        node_name: "{{ print "{{ kubernetes_hostname }}" }}"
    - name: Uncordon node
      delegate_to: localhost
      shell: "sleep 60 && {{ .paths.kubectl }} {{ print "uncordon {{ node_name }} --kubeconfig={{ kubernetes_kubeconfig_path }}admin.conf" }}"
{{ if ne .options.skipPodsRunningCheck true }}
- name: Wait for pods to be in a completed or running state
  hosts: nodes
  tasks:
    - name: Get number of pods not in a completed or running state
      delegate_to: localhost
      shell: "{{ .paths.kubectl }} get pods -A -o wide {{ print "--kubeconfig={{ kubernetes_kubeconfig_path }}admin.conf"}} | grep -cvE 'Running|Completed'"
      register: num_pods_result
      until: "num_pods_result.stdout | int < 2"
      retries: {{ .options.podRunningTimeout | default 10 }}
      delay: 30
{{- end}}
