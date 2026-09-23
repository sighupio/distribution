all:
  children:
    control_plane:
      hosts:
        {{- range $h := .spec.kubernetes.controlPlane.members }}
        {{ $h.hostname }}:
        {{- end }}
      vars:
    # The preflight check probes every machine, and not only the control plane, so that it can
    # tell a first apply from a cluster whose control plane does not answer.
    nodes:
      hosts:
        {{- range $n := .spec.infrastructure.nodes }}
        {{ $n.hostname }}:
        {{- end }}
    load_balancers:
      hosts:
        {{- if hasKeyAny .spec.infrastructure "loadBalancers" }}
        {{- range $h := .spec.infrastructure.loadBalancers.members }}
        {{ $h.hostname }}:
        {{- end }}
        {{- end }}
  vars:
    ansible_python_interpreter: "{{ .spec | digAny "toolsConfiguration" "ansible" "pythonInterpreter" "python3" }}"
    ansible_ssh_private_key_file: "{{ .spec.infrastructure.ssh.privateKeyPath }}"
    ansible_user: "{{ .spec.infrastructure.ssh.username }}"
    kubernetes_kubeconfig_path: ./
