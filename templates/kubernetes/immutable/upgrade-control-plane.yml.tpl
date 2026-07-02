# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.
---
# Control-plane upgrade, serial 1: refresh the kubernetes sysext, renew certs, and kubeadm upgrade apply (restarts the static pods in-band); the post_tasks reboot activates the staged OS (and the swapped kubelet binary, unless its config-patch handler restarted the kubelet first).
- name: Upgrade the control plane
  hosts: control_plane
  serial: 1
  become: true
  vars:
    upgrade: true
    k8s_upgrade: true
    os_update_apply: true
    os_update_reboot: true
  pre_tasks:
    # G10 infra preflight (disk, .raw reachability, A/B rollback) before any disruptive work.
    - name: Infrastructure preflight before the upgrade
      ansible.builtin.include_role:
        name: upgrade-gates
        tasks_from: infra_preflight.yml
    # Launch the OS stage async so the Flatcar download overlaps the sysext staging and the kubeadm apply.
    - name: Stage the operating system update (async)
      ansible.builtin.include_role:
        name: os-upgrade
        tasks_from: os_stage.yml
    # Decide the maintenance window from the single disruptive-node rule, then drain only when required.
    - name: Decide the maintenance window
      ansible.builtin.include_role:
        name: node-maintenance
        tasks_from: preflight.yml
    - name: Open the maintenance window (cordon + drain)
      when: node_upgrade_drain_required
      ansible.builtin.include_role:
        name: node-maintenance
        tasks_from: drain.yml
  roles:
    - containerd
    - kube-control-plane
  post_tasks:
    # Wait on the async OS stage and reboot into the target version (after the kubeadm upgrade has run).
    - name: Reboot into the staged operating system
      ansible.builtin.include_role:
        name: os-upgrade
        tasks_from: os_reboot.yml
    # G6 post-upgrade sanity (binaries/runtime/overlay/Ready) before the node is returned to service.
    - name: Post-upgrade node sanity check
      ansible.builtin.include_role:
        name: upgrade-gates
        tasks_from: sanity.yml
    - name: Close the maintenance window (uncordon + wait for pods)
      when: node_upgrade_drain_required
      ansible.builtin.include_role:
        name: node-maintenance
        tasks_from: uncordon.yml
    # Re-gather facts: the role rebooted the node, so play-start facts are stale.
    - name: Refresh OS facts after the upgrade
      ansible.builtin.setup:
        gather_subset: min
    - name: Report the upgraded version
      ansible.builtin.debug:
        msg: "{{ "{{ inventory_hostname }} upgraded to Kubernetes {{ kubernetes_version }} / Flatcar {{ ansible_facts['distribution_version'] | default('unknown') }}" }}"
  tags:
    - kubeadm-upgrade
