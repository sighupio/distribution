all:
  children:
    control_plane:
      hosts:
        {{- range $h := .spec.kubernetes.controlPlane.members }}
        {{ $h.hostname }}:
        {{- end }}
      vars:
  vars:
    ansible_python_interpreter: "{{ .spec | digAny "toolsConfiguration" "ansible" "pythonInterpreter" "python3" }}"
    ansible_ssh_private_key_file: "{{ .spec.infrastructure.ssh.privateKeyPath }}"
    ansible_user: "{{ .spec.infrastructure.ssh.username }}"
    kubernetes_kubeconfig_path: ./
