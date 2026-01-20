all:
  children:
    control_plane:
      hosts:
        {{- range $h := .spec.kubernetes.controlPlane.members }}
        {{ $h.hostname }}:
        {{- end }}
      vars:
  vars:
    {{- if and (index .spec.kubernetes "advancedAnsible") (index .spec.kubernetes.advancedAnsible "pythonInterpreter") }}
    ansible_python_interpreter: "{{ .spec.kubernetes.advancedAnsible.pythonInterpreter }}"
    {{- else }}
    ansible_python_interpreter: python3
    {{- end }}
    ansible_ssh_private_key_file: "{{ .spec.infrastructure.ssh.privateKeyPath }}"
    ansible_user: "{{ .spec.infrastructure.ssh.username }}"
    kubernetes_kubeconfig_path: ./
