# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# containerd
- name: Containerd install
  hosts: master,nodes
  become: true
  roles:
    - containerd
  tags:
    - containerd

# loadbalancer
- name: Copy CA certificates to HAProxy
  hosts: haproxy
  become: true
  vars:
    pki_dir: "{{ .spec.kubernetes.pkiFolder }}"
  tasks:
    - name: Copy Kubernetes CA
      copy:
        src: "{{ print "{{ pki_dir }}" }}/master/ca.crt"
        dest: /etc/ssl/certs/kubernetes.crt
        owner: root
        group: root
        mode: 0644
  tags:
    - pki

- name: Load balancer installation
  hosts: haproxy
  become: true
  roles:
    - haproxy
  tags:
    - haproxy

- name: Kubernetes node preparation
  hosts: master,nodes,etcd
  become: true
  roles:
    - kube-node-common
  tags:
    - kube-node-common

- name: Etcd cluster preparation
  hosts: etcd
  become: true
  vars:
    etcd_address: "{{ "{{ ansible_host }}" }}"
    etcd_local_pki_dir: "{{ .spec.kubernetes.pkiFolder }}"
  roles:
    - etcd
  tags:
    - etcd

- name: Control plane configuration
  hosts: master
  become: true
  vars:
    kubernetes_local_pki_dir: "{{ .spec.kubernetes.pkiFolder }}"
  serial: 1
  roles:
    - kube-control-plane
  tags:
    - kube-control-plane

- name: Kubernetes join nodes
  hosts: nodes
  become: true
  vars:
    kubernetes_bootstrap_token: "{{ "{{ hostvars[groups.master[0]].kubernetes_bootstrap_token.stdout }}" }}"
    kubernetes_ca_hash: "{{ "{{ hostvars[groups.master[0]].kubernetes_ca_hash.stdout }}" }}"
  roles:
    - kube-worker
  tags:
    - kube-worker

- name: Gather needed information for updating control-plane and nodes labels and annotations
  hosts: nodes, master
  tasks:
    # TODO: furyctl has already checked for this secret, maybe we can pass it on from furyctl to the template engine
    # somehow instead of downloading it again.
    - name: Get previous cluster configuration
      delegate_to: localhost
      ansible.builtin.command: "{{ .paths.kubectl }} {{" get secrets -n kube-system furyctl-config -o jsonpath='{.data.config}' --kubeconfig={{ kubernetes_kubeconfig_path }}admin.conf" }}"
      register: previous_state
      # We ignore the secret not found error because when we init the cluster the secret does not exist yet, so the command fails.
      # Notice that all conditions must be true.
      failed_when:
        - previous_state.rc != 0
        - '"Error from server (NotFound): secrets \"furyctl-config\" not found" not in previous_state.stderr'
      # This is common for all the nodes, just run it once.
      run_once: true

    - name: Deserialize previous cluster configuration into a variable
      delegate_to: localhost
      ansible.builtin.set_fact:
        furyctl_yaml: "{{ "{{ previous_state.stdout | b64decode | from_yaml }}" }}"
      when: previous_state.rc == 0 and previous_state.stdout != "null"
      # This is common for all the nodes, just run it once.
      run_once: true

- name: Preparing control-plane labels and annotations
  hosts: master
  tasks:
    - name: Format control-plane labels and annotations for usage with kubectl
      vars:
        # We calculate the removed labels and annotations so we can pass them as parameters with the appended `-` to delete them from the nodes.
        # If they were not defined in the previous configuration we default to an empty list for calculating the difference.
        # We use the `reject` filter to remove the role label in case it was added manually, so it does not get removed.
        removed_cp_labels: "{{ "{{ furyctl_yaml.spec.kubernetes.masters.labels | default([], true) | difference(kubernetes_node_labels|default([], true)) | reject('match', 'node-role.kubernetes.io/control-plane') }}" }}"
        removed_cp_annotations: "{{ "{{ furyctl_yaml.spec.kubernetes.masters.annotations | default([], true) | difference(kubernetes_node_annotations|default([], true)) }}" }}"
      ansible.builtin.set_fact:
        # We apply all the labels defined in the new configuration and delete the removed ones. We don't care if the rest are new or existed before, we just overwrite.
        node_labels: "{{ "{% for l in kubernetes_node_labels|default([], true) %}{{l}}={{kubernetes_node_labels[l]}} {% endfor %}{% for rl in removed_cp_labels %}{{rl}}- {% endfor %}" }}"
        node_annotations: "{{ "{% for a in kubernetes_node_annotations|default([], true) %} {{a}}={{kubernetes_node_annotations[a]|quote}} {% endfor %} {% for ra in removed_cp_annotations %}{{ra}}- {% endfor %}" }}"
      # We run this once because labels are common for all the control plane hosts.
      run_once: true

- name: Preparing nodes labels and annotations
  hosts: nodes
  tasks:
    - name: Format nodes labels and annotations for usage with kubectl
      vars:
        # For the nodes we can't access directly the labels and annotations properties like we do for the masters
        # because nodes is a list of node groups.
        # We need to identify which element of the `nodes` list is the right one for this node.
        node_group_details: "{{ "{{ furyctl_yaml.spec.kubernetes.nodes | selectattr('name', '==', kubernetes_role) | first }}" }}"
        # We calculate the removed labels and annotations accessing the element of the `nodes` property we got in the previous line.
        # We use the `reject` filter to remove the role label in case it was added manually, so it does not get removed.
        node_role_label: {{ "node-role.kubernetes.io/{{ kubernetes_role }}" }}
        removed_node_labels: "{{ "{{ node_group_details.labels|default([], true) | difference(kubernetes_node_labels|default([], true)) | reject('match', node_role_label) }}" }}"
        removed_node_annotations: "{{ "{{ node_group_details.annotations|default([], true) | difference(kubernetes_node_annotations|default([], true)) }}" }}"
      ansible.builtin.set_fact:
        node_labels: "{{ "{% for l in kubernetes_node_labels|default([], true) %}{{l}}={{kubernetes_node_labels[l]}} {% endfor %}{% for rl in removed_node_labels %}{{rl}}- {% endfor %}" }}"
        node_annotations: "{{ "{% for a in kubernetes_node_annotations|default([], true) %} {{a}}={{kubernetes_node_annotations[a]|quote}} {% endfor %} {% for ra in removed_node_annotations %}{{ra}}- {% endfor %}" }}"

- name: Update control-plane and nodes labels and annotations
  hosts: nodes, master
  tasks:

    # We set here the label that determines the node role because the kubelet can't do it for security reasons.
    # We set by default the role to be the name of the node group in the furyctl.yaml file.
    # We do this only for the regular nodes. We don't need to do this for the control plane because kubeadm configures
    # the kubelet to do it automatically.
    - name: Set nodes role based on the node group's name
      delegate_to: localhost
      ansible.builtin.command: "{{ .paths.kubectl }} {{ "label node {{ kubernetes_hostname }} node-role.kubernetes.io/{{ kubernetes_role }}= --kubeconfig={{ kubernetes_kubeconfig_path }}admin.conf" }}"
      when: kubernetes_role is defined

    # Update the control plane and nodes labels with what we calculated before only if needed.
    - name: Update node labels
      delegate_to: localhost
      ansible.builtin.command: "{{ .paths.kubectl }} {{ "label node {{ kubernetes_hostname }} {{ node_labels }} --overwrite --kubeconfig={{ kubernetes_kubeconfig_path }}admin.conf" }}"
      when: node_labels is defined and node_labels|trim not in ['', 'None']

    # Update the control plane and nodes annotations with what we calculated before only if needed.
    - name: Update node annotations
      delegate_to: localhost
      ansible.builtin.command: "{{ .paths.kubectl }} {{ "annotate node {{ kubernetes_hostname }} {{ node_annotations }} --overwrite --kubeconfig={{ kubernetes_kubeconfig_path }}admin.conf" }}"
      when: node_annotations is defined and node_annotations|trim not in ['', 'None']
