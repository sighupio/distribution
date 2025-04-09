# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

- name: Verify that the cluster exists
  hosts: master
  become: true
  tasks:
    - name: Check that the /etc/kubernetes/admin.conf exists
      stat:
        path: /etc/kubernetes/admin.conf
      register: admin_conf_stat

    - name: Set fact if admin.conf exists
      set_fact:
        admin_conf_exists: "{{"{{ admin_conf_stat.stat.exists }}"}}"
      when: admin_conf_stat.stat.exists

- name: Aggregate results and fetch admin.conf
  hosts: master
  tasks:
    - name: Initialize any_master_has_conf
      set_fact:
        any_master_has_conf: false

    - name: Check if any master has admin.conf
      set_fact:
        any_master_has_conf: "{{"{{ any_master_has_conf or hostvars[item].admin_conf_exists }}"}}"
      loop: "{{"{{ groups['master'] }}"}}"
      when: hostvars[item].admin_conf_exists is defined

    - name: Fail if no master has admin.conf
      fail:
        msg: "No master node has /etc/kubernetes/admin.conf"
      when: not any_master_has_conf
 