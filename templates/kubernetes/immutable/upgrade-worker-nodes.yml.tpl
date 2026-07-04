# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.
---
# Worker upgrade: stage, reboot to activate at boot, then kubeadm (reboot runs inside the kube-worker role).
# serial defaults to 1; workers run no etcd, so raising it (opt-in) parallelizes the worker phase without
# touching quorum — real concurrency is bounded by PodDisruptionBudgets + the drain --timeout.
- name: Upgrade the worker nodes
  hosts: nodes
  serial: {{ .options | digAny "workerUpgradeSerial" 1 }}
  become: true
  vars:
    upgrade: true
    os_update_apply: true
    os_update_reboot: true
    skip_pods_running_check: {{ .options | digAny "skipPodsRunningCheck" false }}
    pods_running_retries: {{ .options.podRunningTimeout | default 10 }}
  pre_tasks:
    # Acquire super-admin.conf on the controller before any controller-side kubectl check. A single-node
    # `--upgrade-node` runs ONLY this play, so it can't rely on the etcd play's fetch.
    - name: Acquire super-admin.conf for the controller-side kubectl checks
      run_once: true
      ansible.builtin.include_role:
        name: upgrade-gates
        tasks_from: fetch_admin_conf.yml
    # G10 infra preflight (disk, .raw reachability, A/B rollback) before any disruptive work.
    - name: Infrastructure preflight before the upgrade
      ansible.builtin.include_role:
        name: upgrade-gates
        tasks_from: infra_preflight.yml
    # Launch the OS stage async so the Flatcar download overlaps the sysext staging and drain before the role reboots.
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
    - kube-worker
  post_tasks:
    # G6 post-upgrade sanity (binaries/runtime/overlay/Ready) before the node is returned to service.
    - name: Post-upgrade node sanity check
      ansible.builtin.include_role:
        name: upgrade-gates
        tasks_from: sanity.yml
    # Uncordon + baseline-relative pod-settle wait, only when the node was drained.
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
    - kube-worker

# Remove the fetched super-admin.conf (system:masters) from the controller workdir once the whole worker phase
# finishes. A dedicated localhost play (not a serial post_task), so it runs exactly once, after all nodes.
- name: Clean up the controller super-admin.conf
  hosts: localhost
  gather_facts: false
  become: false
  tasks:
    - name: Remove the fetched super-admin.conf from the controller
      ansible.builtin.file:
        path: ./super-admin.conf
        state: absent
