# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.
---
# Collect the facts of every control plane before the upgrade starts.
#
# The upgrade play uses `serial: 1`, which gathers only the host of the batch. The keepalived.conf
# template builds its peer list from the facts of every host of the group.
- name: Gather facts from every control plane
  hosts: control_plane
  become: false
  gather_facts: true
  post_tasks:
    # Stop before any work unless every control plane answered: the keepalived.conf render needs
    # their facts, and the upgrade needs every etcd member and API server anyway.
    - name: Fail when a control plane does not answer
      run_once: true
      ansible.builtin.assert:
        that:
          - ansible_play_hosts_all | difference(ansible_play_hosts) | length == 0
        fail_msg: "{{ "These control planes did not answer: {{ ansible_play_hosts_all | difference(ansible_play_hosts) | join(', ') }}. Every control plane must answer before the upgrade starts." }}"
        success_msg: "{{ "All {{ ansible_play_hosts_all | length }} control planes answered." }}"

# Control-plane upgrade (serial:1): sysext refresh, cert renewal, kubeadm upgrade apply (in-band static-pod restart), then reboot to activate the staged OS.
- name: Upgrade the control plane
  hosts: control_plane
  serial: 1
  become: true
  vars:
    upgrade: true
    os_update_apply: true
    os_update_reboot: true
  pre_tasks:
    # Infra preflight (disk, .raw reachability, A/B rollback) before any disruptive work.
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
    # Aligns the VIP extension and rewrites its configuration, also when the VIP is disabled:
    # butane installs the extension on every control plane. The reboot below activates it.
    - keepalived
  post_tasks:
    # Wait on the async OS stage and reboot into the target version (after the kubeadm upgrade has run).
    - name: Reboot into the staged operating system
      ansible.builtin.include_role:
        name: os-upgrade
        tasks_from: os_reboot.yml
    # Post-upgrade sanity (binaries/runtime/overlay/Ready) before the node is returned to service.
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
