# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.
---
{{- $controlPlaneAddress := .spec.kubernetes.controlPlane.address }}
{{- $etcdOnControlPlane := true }}
{{- $etcdMembers := .spec.kubernetes.controlPlane.members }}
{{- if gt ( .spec.kubernetes | digAny "etcd" "members" list | len ) 0 }}
  {{- $etcdOnControlPlane = false }}
  {{- $etcdMembers = .spec.kubernetes.etcd.members }}
{{- end }}

{{- if not $etcdOnControlPlane }}
- name: Set up etcd cluster on dedicated nodes
  hosts: etcd
  become: true
  roles:
    - etcd
  tags:
    - etcd
{{- end }}

# TODO: que pasa cuando no quiero usar keepalived entonces no lo especifico en el furyctl.yaml?
- name: Set up Control Plane VIP
  become: true
  roles:
    - keepalived
  hosts:
    - control_plane
  tags:
    - kube-control-plane-vip

- name: Set up containerd and etcd on Control Plane
  become: true
  roles:
    - containerd
    {{- if $etcdOnControlPlane }}
    - etcd
    {{- end }}
  hosts:
    - control_plane
  tags:
    - kube-control-plane
    - kube-control-plane-containerd
    {{- if $etcdOnControlPlane }}
    - etcd
    {{- end }}

- name: Set up Kubernetes Control Plane
  become: true
  serial: 1
  roles:
    - kube-control-plane
  hosts:
    - control_plane
  tags:
    - kube-control-plane

- name: Set up Kubernetes Nodes containerd
  hosts: nodes
  become: true
  roles:
    - containerd
  tags:
    - kube-worker

- name: Set up Kubernetes Nodes
  hosts: nodes
  become: true
  vars:
    kubernetes_bootstrap_token: "{{ "{{ hostvars[groups.control_plane[0]].kubernetes_bootstrap_token.stdout }}" }}"
    kubernetes_ca_hash: "{{ "{{ hostvars[groups.control_plane[0]].kubernetes_ca_hash.stdout }}" }}"
  roles:
    - kube-worker
  tags:
    - kube-worker

- import_playbook: nodes-labels-annotations.yaml
