all:
  children:
    load_balancers:
      hosts:
        {{- if hasKeyAny .spec.infrastructure "loadBalancers" }}
        {{- range $h := .spec.infrastructure.loadBalancers.members }}
        {{ $h.hostname }}:
        {{- end }}
        {{- end }}
      vars:
        {{- if hasKeyAny .spec.infrastructure "loadBalancers" }}
        {{- if index .spec.infrastructure.loadBalancers "keepalived" }}
        keepalived_cluster: {{ .spec.infrastructure.loadBalancers.keepalived.enabled }}
        keepalived_on_controlplane: false
        keepalived_ansible_group_name: load_balancers
        keepalived_ip: {{ .spec.infrastructure.loadBalancers.keepalived.ip }}
          {{- if index .spec.infrastructure.loadBalancers.keepalived "passphrase" }}
        keepalived_passphrase: {{ .spec.infrastructure.loadBalancers.keepalived.passphrase }}
          {{- end }}
          {{- if index .spec.infrastructure.loadBalancers.keepalived "virtualRouterId" }}
        keepalived_virtual_router_id: {{ .spec.infrastructure.loadBalancers.keepalived.virtualRouterId }}
          {{- end }}
          {{- if index .spec.infrastructure.loadBalancers.keepalived "interface" }}
        keepalived_interface: {{ .spec.infrastructure.loadBalancers.keepalived.interface }}
          {{- end }}
        {{- end }}
        haproxy_configuration: |
          {{- if (.spec | digAny "infrastructure" "loadBalancers" "haproxy" "configuration" false) }}
{{ .spec.infrastructure.loadBalancers.haproxy.configuration | trim | indent 10 }}
          {{- else }}
          frontend k8s-api-server
              mode tcp
              bind *:6443 alpn h2,http/1.1
              default_backend control-plane
              timeout client 50s

          backend control-plane
              option httpchk GET /healthz
              balance roundrobin
              timeout connect 5s
              timeout server 50s
              {{- range $h := .spec.kubernetes.controlPlane.members }}
              server {{ $h.hostname }} {{ $h.hostname }}:6443 check check-ssl ca-file /usr/local/etc/haproxy/kubernetes.crt
              {{- end }}
          {{- end }}
        {{- if index .spec.infrastructure.loadBalancers "haproxy" }}
          {{- if index .spec.infrastructure.loadBalancers.haproxy "image" }}
        haproxy_container_image: "{{ .spec.infrastructure.loadBalancers.haproxy.image }}"
          {{- end }}
          {{- if index .spec.infrastructure.loadBalancers.haproxy "tag" }}
        haproxy_container_tag: "{{ .spec.infrastructure.loadBalancers.haproxy.tag }}"
          {{- end }}
        {{- end }}
        kubernetes_local_pki_dir: "{{ .spec.kubernetes.pkiPath }}/master"
        {{- if (index .spec.infrastructure.loadBalancers "containerd") }}
        {{- $containerd := .spec.infrastructure.loadBalancers.containerd }}
        {{- if (index $containerd "registryConfigs") }}
        containerd_registry_configs:
          {{- range $rc := $containerd.registryConfigs }}
          - registry: {{ $rc.registry }}
            {{- if index $rc "username" }}
            username: {{ $rc.username }}
            {{- end }}
            {{- if index $rc "password" }}
            password: {{ $rc.password }}
            {{- end }}
            {{- if index $rc "insecureSkipVerify" }}
            insecure_skip_verify: {{ $rc.insecureSkipVerify }}
            {{- end }}
            {{- if index $rc "mirrorEndpoint" }}
            mirror_endpoint:
{{ $rc.mirrorEndpoint | toYaml | indent 14 }}
            {{- end }}
          {{- end }}
        {{- end }}
        {{- if hasKeyAny $containerd "selfmanagedRepositories" }}
        containerd_self_managed_repositories: {{ $containerd.selfmanagedRepositories }}
        {{- end }}
        {{- if hasKeyAny $containerd "storageDir" }}
        containerd_storage_dir: "{{ $containerd.storageDir }}"
        {{- end }}
        {{- if hasKeyAny $containerd "stateDir" }}
        containerd_state_dir: "{{ $containerd.stateDir }}"
        {{- end }}
        {{- if hasKeyAny $containerd "systemdDir" }}
        containerd_systemd_dir: "{{ $containerd.systemdDir }}"
        {{- end }}
        {{- if hasKeyAny $containerd "oomScore" }}
        containerd_oom_score: {{ $containerd.oomScore }}
        {{- end }}
        {{- if hasKeyAny $containerd "grpcMaxRecvMessageSize" }}
        containerd_grpc_max_recv_message_size: {{ $containerd.grpcMaxRecvMessageSize }}
        {{- end }}
        {{- if hasKeyAny $containerd "grpcMaxSendMessageSize" }}
        containerd_grpc_max_send_message_size: {{ $containerd.grpcMaxSendMessageSize }}
        {{- end }}
        {{- if hasKeyAny $containerd "debugLevel" }}
        containerd_debug_level: "{{ $containerd.debugLevel }}"
        {{- end }}
        {{- if hasKeyAny $containerd "metricsAddress" }}
        containerd_metrics_address: "{{ $containerd.metricsAddress }}"
        {{- end }}
        {{- if hasKeyAny $containerd "metricsGrpcHistogram" }}
        containerd_metrics_grpc_histogram: {{ $containerd.metricsGrpcHistogram }}
        {{- end }}
        {{- if hasKeyAny $containerd "maxContainerLogLineSize" }}
        containerd_max_container_log_line_size: {{ $containerd.maxContainerLogLineSize }}
        {{- end }}
        {{- if hasKeyAny $containerd "deviceOwnershipFromSecurityContext" }}
        containerd_device_ownership_from_security_context: {{ $containerd.deviceOwnershipFromSecurityContext }}
        {{- end }}
        {{- end }}
        {{- end }}
    nodes:
      hosts:
        {{- range $n := .spec.infrastructure.nodes }}
        {{ $n.hostname }}:
          {{- if index $n "kernelParameters" }}
          kernel_parameters:
            {{ $n.kernelParameters | toYaml | indent 12 | trim }}
          {{- end -}}
        {{- end }}
  vars:
    ansible_python_interpreter: "{{ .spec | digAny "toolsConfiguration" "ansible" "pythonInterpreter" "python3" }}"
    ansible_ssh_private_key_file: "{{ .spec.infrastructure.ssh.privateKeyPath }}"
    ansible_user: "{{ .spec.infrastructure.ssh.username }}"
    {{- if (index .spec.infrastructure "proxy") }}
    http_proxy: "{{ .spec.infrastructure.proxy | digAny "http" "" }}"
    https_proxy: "{{ .spec.infrastructure.proxy | digAny "https" "" }}"
    no_proxy: "{{ .spec.infrastructure.proxy | digAny "noProxy" "" }}"
    {{- end }}
