# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.
#
# Kubernetes PKI certificates renewal playbook
#
# This playbook automates the Kubernetes certificates renewal process, it performs:
#   1. Renew Control Plane certificates.
#   2. Renew Kubelet certificates.
#   3. Print all certificates expiration dates for check.
#
# Check for expiration first e.g. via executing the following on a master node via:
#
#   find /etc/kubernetes/pki /etc/etcd/pki -type f -name "*.crt" -print | sort |
#   egrep -v 'ca\.crt$|\/pki\/expired\/|\/tmp\/|ca-bundle\.' |
#   xargs -L 1 -t  -i bash -c 'openssl x509  -noout -text -in {} | grep After'
#
# or via:
#
#   find /etc/kubernetes -type f -name '*.conf' |
#   grep -v expired |
#   xargs -L 1 -t -i bash -c 'kubectl config view --raw -o jsonpath="{.users[0].user.client-certificate-data}" --kubeconfig={} | base64 -d | openssl x509 -noout -text | grep After'
#
# In case the certificates are close to expiring, this playbook can be used to renew them.

- name: Renew Kubernetes PKI certificates
  hosts: master,etcd
  become: true
  serial: 1
  tasks:

    - name: Get the current Kubernetes version
      command: kubectl version --kubeconfig=/etc/kubernetes/admin.conf -o json
      register: json_output
      when: inventory_hostname in groups['master']

    - name: Set Kubernetes version
      set_fact:
        kubernetes_version: "{{ "{{ (json_output.stdout | from_json).serverVersion.major }}.{{ (json_output.stdout | from_json).serverVersion.minor }}" }}"
      when: inventory_hostname in groups['master']

    - name: Set backup timestamp
      set_fact:
        backup_timestamp: "{{ "{{ lookup('pipe', 'date +%Y-%m-%d_%H-%M-%S') }}" }}"

    - name: Ensure Kubernetes backup directory exists
      file:
        path: "{{ "{{ ansible_env.HOME }}" }}/certs-backup/{{ print "{{ backup_timestamp }}" }}/etc-kubernetes-pki"
        state: directory
        mode: '0750'
      when: inventory_hostname in groups['master']

    - name: Ensure etcd backup directory exists
      file:
        path: "{{ "{{ ansible_env.HOME }}" }}/certs-backup/{{ print "{{ backup_timestamp }}" }}/etc-etcd-pki"
        state: directory
        mode: '0750'
      when: inventory_hostname in groups['etcd']

    - name: Backup Kubernetes certificates
      copy:
        src: /etc/kubernetes/pki/
        dest: "{{ "{{ ansible_env.HOME }}" }}/certs-backup/{{ print "{{ backup_timestamp }}" }}/etc-kubernetes-pki"
        remote_src: yes
        mode: preserve
        directory_mode: '0750'
      when: inventory_hostname in groups['master']

    - name: Backup etcd certificates
      copy:
        src: /etc/etcd/pki/
        dest: "{{ "{{ ansible_env.HOME }}" }}/certs-backup/{{ print "{{ backup_timestamp }}" }}/etc-etcd-pki"
        remote_src: yes
        mode: preserve
        directory_mode: '0750'
      when: inventory_hostname in groups['etcd']

    - name: Renew Kubernetes control plane certs
      shell: |
        kubeadm certs renew admin.conf
        kubeadm certs renew apiserver
        kubeadm certs renew apiserver-kubelet-client
        kubeadm certs renew controller-manager.conf
        kubeadm certs renew front-proxy-client
        kubeadm certs renew scheduler.conf
      when: inventory_hostname in groups['master']

    - name: Renew etcd certificates
      shell: |
        kubeadm certs renew --config=/etc/etcd/kubeadm-etcd.yml --cert-dir=/etc/etcd/pki apiserver-etcd-client
        kubeadm certs renew --config=/etc/etcd/kubeadm-etcd.yml --cert-dir=/etc/etcd/pki etcd-healthcheck-client
        kubeadm certs renew --config=/etc/etcd/kubeadm-etcd.yml --cert-dir=/etc/etcd/pki etcd-peer
        kubeadm certs renew --config=/etc/etcd/kubeadm-etcd.yml --cert-dir=/etc/etcd/pki etcd-server
      when: inventory_hostname in groups['etcd']

    - name: Renew Kubernetes super-admin.conf (only if Kubernetes version >= 1.29)
      shell: kubeadm certs renew super-admin.conf
      when:
        - inventory_hostname in groups['master']
        - kubernetes_version is version('1.29', '>=')

- name: Distribute etcd certificates from etcd to control plane nodes
  hosts: master
  become: true
  vars:
    etcd_certs:
      - etcd/ca.crt
      - apiserver-etcd-client.crt
      - apiserver-etcd-client.key
  tasks:
    - name: Retrieving certificates from etcd nodes
      run_once: true
      delegate_to: "{{ "{{ groups.etcd[0] }}" }}"
      fetch:
        src: "/etc/etcd/pki/{{ print "{{ item }}" }}"
        dest: "/tmp/etcd-certs/"
        flat: yes
      with_items: "{{ "{{ etcd_certs }}" }}"
      when: not etcd_on_control_plane

    - name: Copying certificates to control plane nodes
      copy:
        src: "/tmp/etcd-certs/{{ print "{{ item | basename }}" }}"
        dest: "/etc/etcd/pki/{{ print "{{ item }}" }}"
        owner: root
        group: root
        mode: 0640
      with_items: "{{ "{{ etcd_certs }}" }}"
      when: not etcd_on_control_plane

    - name: Cleaning up temporary certificates
      run_once: true
      become: false
      delegate_to: localhost
      file:
        path: /tmp/etcd-certs
        state: absent
      when: not etcd_on_control_plane

- name: Restart etcd and control plane components
  hosts: etcd,master
  become: true
  serial: 1
  tasks:
    - name: Restart etcd
      shell: systemctl restart etcd
      when: inventory_hostname in groups['etcd']

    - name: Wait for etcd to be running
      shell: systemctl is-active etcd --quiet
      register: etcd_status
      retries: 10
      delay: 5
      until: etcd_status.rc == 0
      when: inventory_hostname in groups['etcd']

    - name: Restart control plane components
      shell: |
        crictl ps -q --name 'kube-(controller-manager|scheduler|apiserver)' | xargs -r crictl stop
        crictl ps -a -q --state exited --name 'kube-(apiserver|controller-manager|scheduler)' | xargs -r crictl rm
      when: inventory_hostname in groups['master']

    - name: Wait for kube-controller-manager to be running
      shell: crictl ps --name kube-controller-manager | grep -q Running
      register: kube_controller_manager_status
      retries: 10
      delay: 5
      until: kube_controller_manager_status.rc == 0
      when: inventory_hostname in groups['master']

    - name: Wait for kube-scheduler to be running
      shell: crictl ps --name kube-scheduler | grep -q Running
      register: kube_scheduler_status
      retries: 10
      delay: 5
      until: kube_scheduler_status.rc == 0
      when: inventory_hostname in groups['master']

    - name: Wait for kube-apiserver to be running
      shell: crictl ps --name kube-apiserver | grep -q Running
      register: kube_apiserver_status
      retries: 10
      delay: 5
      until: kube_apiserver_status.rc == 0
      when: inventory_hostname in groups['master']

- name: Renew Kubelet certificates
  hosts: master,nodes
  become: true
  serial: 1
  tasks:

    - name: Ensure Kubelet client certificate auto-renewal
      block:
      - name: Check whether it's already done
        shell: cat /etc/kubernetes/kubelet.conf | grep /var/lib/kubelet/pki/kubelet-client-current.pem
      rescue:
      - name: Remove static client cert from kubelet.conf
        lineinfile:
          path: /etc/kubernetes/kubelet.conf
          state: absent
          regexp: '.*client-certificate-data.*'
      - name: Remove static client key from kubelet.conf
        lineinfile:
          path: /etc/kubernetes/kubelet.conf
          state: absent
          regexp: '.*client-key-data.*'
      - name: Link kubelet.conf to kubelet-client-current.pem
        blockinfile:
          path: /etc/kubernetes/kubelet.conf
          marker: ""
          insertafter: "user:"
          content: |4
                  client-certificate: /var/lib/kubelet/pki/kubelet-client-current.pem
                  client-key: /var/lib/kubelet/pki/kubelet-client-current.pem
      - name: Remove the blank line from the previous "blockinfile" task
        lineinfile :
          path: /etc/kubernetes/kubelet.conf
          state: absent
          regexp: '^$'

    - name: Delete the Kubelet server cert before regenarating them
      file:
        path: "{{ "{{ item }}" }}"
        state: absent
      with_items:
        - /var/lib/kubelet/pki/kubelet.crt
        - /var/lib/kubelet/pki/kubelet.key

    - name: Restart Kubelet and regenerate the server certificate
      shell: |
        systemctl restart kubelet.service

    - name: Check if Kubelet is running
      shell: systemctl is-active kubelet --quiet
      register: kubelet_status
      retries: 10
      delay: 5
      until: kubelet_status.rc == 0


- name: Print Control Plane certificates expiration dates
  hosts: master
  become: true
  tasks:
    - name: Print certificates expiration dates
      shell: |
        find /etc/kubernetes/pki /etc/etcd/pki -type f -name "*.crt" -print | sort |
        egrep -v 'ca\.crt$|\/pki\/expired\/|\/tmp\/|ca-bundle\.' |
        xargs -L 1 -t  -i bash -c 'openssl x509  -noout -text -in {} | grep After'
      register: pki_info
    - debug: var=pki_info.stdout_lines

    - name: Print kubeconfig expiration dates (expected 'unable to load certificate' error)
      ignore_errors: true # error with message 'unable to load certificate' are expected here
      shell: |
        find /etc/kubernetes -type f -name '*.conf' |
        egrep -v 'expired' |
        xargs -L 1 -t -i bash -c 'kubectl config view --kubeconfig=/etc/kubernetes/admin.conf --raw -o jsonpath="{.users[0].user.client-certificate-data}" --kubeconfig={} | base64 -d | openssl x509 -noout -text | grep After'
      register: kconfig_info
    - debug: var=kconfig_info.stdout_lines

- name: Print etcd certificates expiration dates
  hosts: etcd
  become: true
  tasks:
    - name: Print certificates expiration dates
      shell: |
        find /etc/etcd/pki -type f -name "*.crt" -print | sort |
        egrep -v 'ca\.crt$|\/pki\/expired\/|\/tmp\/|ca-bundle\.' |
        xargs -L 1 -t  -i bash -c 'openssl x509  -noout -text -in {} | grep After'
      register: etcd_pki_info
    - debug: var=etcd_pki_info.stdout_lines

- name: Print Kubelet certificates expiration dates
  hosts: master,nodes
  become: true
  tasks:
    - name: Print Kubelet certificates expiration dates
      shell: |
        curl -kv https://127.0.0.1:10250 2>&1 | grep expire
      register: kubelet_info
    - debug: var=kubelet_info.stdout_lines
