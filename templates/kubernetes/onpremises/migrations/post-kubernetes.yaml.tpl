# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Reducer-driven migration playbook for the kubernetes phase.
# furyctl runs this playbook (passing the reducers as extra-vars) only when a
# rule with `lifecycle: post-kubernetes` matched a diff. Currently the only such
# rule is `.spec.kubernetes.advanced.kubeProxy.type`, and the only transitions
# that reach here are `ipvs -> nftables` and `nil -> nftables` (every other
# direction is blocked by the `unsupported` rules at preflight).
#
# It runs on the control plane: the kubeadm config (/etc/kubernetes/kubeadm.yml)
# already carries `mode: nftables` (rendered from kubeProxy.type), so we just
# regenerate the kube-proxy ConfigMap from it via `kubeadm init phase addon
# kube-proxy` and restart the DaemonSet. This needs no extra tooling (no yq) and
# no kubeconfig outside the node. The play is idempotent: if kube-proxy is
# already on nftables it ends early.
#
# On Calico it also switches the Tigera dataplane to nftables, in the same phase:
# kube-proxy on nftables with Calico still on the iptables dataplane can clash, so
# both must move together — doing it only in the distribution phase would leave a
# broken state if the user stops at the kubernetes phase. This overlaps with the
# distribution networking templates (which also set the nftables dataplane when
# kubeProxy.type is nftables), but it is idempotent: same value, applied with a
# merge patch. Cilium needs no CNI change, so that task is skipped there.

- name: Migrate kube-proxy to nftables mode
  hosts: master[0]
  become: true
  gather_facts: false
  run_once: true
  tasks:
    - name: Skip migration when the kubeProxyType reducer is not requesting nftables
      ansible.builtin.meta: end_play
      when: reducers.kubeProxyType is not defined or reducers.kubeProxyType.to | default('') != 'nftables'

    - name: Check if kube-proxy is already using nftables
      ansible.builtin.shell: "kubectl --kubeconfig /etc/kubernetes/admin.conf logs -n kube-system daemonset/kube-proxy 2>/dev/null | grep -i 'Using nftables Proxier'"
      register: nftables_check
      failed_when: false
      changed_when: false

    - name: End play if kube-proxy is already on nftables
      ansible.builtin.meta: end_play
      when: nftables_check.rc == 0

    - name: Regenerate the kube-proxy ConfigMap from the kubeadm config (mode is already nftables)
      ansible.builtin.command: "kubeadm init phase addon kube-proxy --config /etc/kubernetes/kubeadm.yml"

    - name: Restart the kube-proxy DaemonSet
      ansible.builtin.command: "kubectl --kubeconfig /etc/kubernetes/admin.conf rollout restart -n kube-system daemonset/kube-proxy"

    - name: Wait for the kube-proxy rollout to complete
      ansible.builtin.command: "kubectl --kubeconfig /etc/kubernetes/admin.conf rollout status -n kube-system daemonset/kube-proxy --timeout=300s"

    - name: Verify kube-proxy switched to nftables
      ansible.builtin.shell: "kubectl --kubeconfig /etc/kubernetes/admin.conf logs -n kube-system daemonset/kube-proxy 2>/dev/null | grep -i 'Using nftables Proxier'"
      register: nftables_verify
      retries: 5
      delay: 10
      until: nftables_verify.rc == 0
      changed_when: false

    - name: Check if Calico (Tigera operator) is installed
      ansible.builtin.command: "kubectl --kubeconfig /etc/kubernetes/admin.conf get installation.operator.tigera.io default -o name"
      register: calico_check
      failed_when: false
      changed_when: false

    - name: Patch the Calico Installation to the nftables dataplane
      ansible.builtin.command: >
        kubectl --kubeconfig /etc/kubernetes/admin.conf patch installation.operator.tigera.io default --type=merge
        -p '{"spec":{"calicoNetwork":{"linuxDataplane":"Nftables"}}}'
      when: calico_check.rc == 0
