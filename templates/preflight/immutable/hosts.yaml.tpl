all:
  children:
    control_plane:
      hosts:
        {{- range $h := .spec.kubernetes.controlPlane.members }}
        {{ $h.hostname }}:
        {{- end }}
      vars:
  vars:
    {{- if and (index .spec.toolsConfiguration "ansible") (index .spec.toolsConfiguration.ansible "pythonInterpreter") }}
    ansible_python_interpreter: "{{ .spec.toolsConfiguration.ansible.pythonInterpreter }}"
    {{- else }}
    ansible_python_interpreter: python3
    {{- end }}
    ansible_ssh_private_key_file: "{{ .spec.infrastructure.ssh.privateKeyPath }}"
    ansible_user: "{{ .spec.infrastructure.ssh.username }}"
    kubernetes_kubeconfig_path: ./
