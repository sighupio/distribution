# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.
---
# Collect the facts of every load balancer before the upgrade starts.
#
# The upgrade play uses `serial: 1`, which gathers one host per batch, and a single-host run
# gathers only its target. Neither one gives the keepalived.conf template the facts of the
# whole group that its peer list needs.
- name: Gather facts from every load balancer
  hosts: load_balancers
  become: false
  gather_facts: true
  post_tasks:
    # Stop before any work unless every load balancer answered.
    #
    # The keepalived.conf template builds its peer list from the facts of every host of the
    # group. A host that did not answer has no facts, so that render fails later with a
    # message about a missing fact. The reboot below also needs a live peer to take the
    # virtual IP address.
    #
    # This task has no condition, although both reasons need keepalived. Ansible ends a run
    # with exit code 4 when a host did not answer. Without this task the run upgrades and
    # reboots a load balancer, and then reports a failure. A cluster with one load balancer
    # always passes this test.
    - name: Fail when a load balancer does not answer
      run_once: true
      ansible.builtin.assert:
        that:
          - ansible_play_hosts_all | difference(ansible_play_hosts) | length == 0
        fail_msg: "{{ "These load balancers did not answer: {{ ansible_play_hosts_all | difference(ansible_play_hosts) | join(', ') }}. Every load balancer must answer before the upgrade starts." }}"
        success_msg: "{{ "All {{ ansible_play_hosts_all | length }} load balancers answered." }}"

# Upgrade the load balancers: stage the OS, align the extensions, rewrite the configuration,
# then reboot.
#
# `serial: 1` keeps the keepalived virtual IP address available, because the host that reboots
# hands it to a peer. A load balancer is not a Kubernetes node, so there is no cordon and no
# drain here.
#
# `lb_upgrade_target` selects one host, and the default is the whole group. Do not select a
# host with --limit: that also filters the fact-gathering play above and breaks the peer list.
- name: Upgrade the load balancers
  hosts: "{{ "{{ lb_upgrade_target | default('load_balancers') }}" }}"
  serial: 1
  become: true
  vars:
    # The containerd and keepalived roles align their system extensions when this is true.
    upgrade: true
    os_update_apply: true
    os_update_reboot: true
  pre_tasks:
    # Stage the OS update first so the Flatcar download overlaps the role work below.
    - name: Stage the operating system update
      ansible.builtin.include_role:
        name: os-upgrade
        tasks_from: os_stage.yml
  roles:
    # The containerd role aligns its extension. The haproxy and keepalived roles rewrite
    # their configuration. The new binaries activate at the reboot in post_tasks, and not
    # by a restart here.
    - containerd
    - haproxy
    - keepalived
  post_tasks:
    - name: Reboot into the staged operating system and extensions
      ansible.builtin.include_role:
        name: os-upgrade
        tasks_from: os_reboot.yml
    # Re-gather facts: the reboot above makes the play-start facts stale.
    - name: Refresh OS facts after the upgrade
      ansible.builtin.setup:
        gather_subset: min
    - name: Report the upgraded version
      ansible.builtin.debug:
        msg: "{{ "{{ inventory_hostname }} upgraded to Flatcar {{ ansible_facts['distribution_version'] | default('unknown') }}" }}"
  tags:
    - load-balancers
