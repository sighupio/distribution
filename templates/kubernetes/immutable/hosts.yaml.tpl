{{- $controlPlaneAddress := .spec.kubernetes.controlPlane.address }}
{{- $etcdOnControlPlane := true }}
{{- $etcdMembers := .spec.kubernetes.controlPlane.members }}
{{- if gt ( .spec.kubernetes | digAny "etcd" "members" list | len ) 0 }}
  {{- $etcdOnControlPlane = false }}
  {{- $etcdMembers = .spec.kubernetes.etcd.members }}
{{- end }}
{{- $etcdInitialCluster := list }}
{{- $etcdEndpoints := list }}
{{- range $h := $etcdMembers }}
    {{- $etcdInitialCluster = append $etcdInitialCluster (print $h.hostname "=https://" $h.hostname ":2380") }}
    {{- $etcdEndpoints = append $etcdEndpoints (print "https://" $h.hostname ":2379") }}
{{- end }}
all:
  children:
    control_plane:
      hosts:
        {{- range $h := .spec.kubernetes.controlPlane.members }}
        {{ $h.hostname }}:
        {{- end }}
      vars:
        {{- if index .spec.kubernetes.controlPlane "keepalived" }}
        keepalived_cluster: {{ .spec.kubernetes.controlPlane.keepalived.enabled }}
        keepalived_on_controlplane: true
        keepalived_ansible_group_name: control_plane
        keepalived_ip: {{ .spec.kubernetes.controlPlane.keepalived.ip }}
        {{- if index .spec.kubernetes.controlPlane.keepalived "passphrase" }}
        keepalived_passphrase: {{ .spec.kubernetes.controlPlane.keepalived.passphrase }}
        {{- end }}
        {{- if index .spec.kubernetes.controlPlane.keepalived "virtualRouterId" }}
        keepalived_virtual_router_id: {{ .spec.kubernetes.controlPlane.keepalived.virtualRouterId }}
        {{- end }}
        {{- if index .spec.kubernetes.controlPlane.keepalived "interface" }}
        keepalived_interface: {{ .spec.kubernetes.controlPlane.keepalived.interface }}
        {{- end }}
        {{- end }}
        kubernetes_cluster_name: "{{ .metadata.name }}"
        kubernetes_pod_cidr: "{{ .spec.kubernetes.networking.podCIDR }}"
        kubernetes_svc_cidr: "{{ .spec.kubernetes.networking.serviceCIDR }}"
        {{- if hasKeyAny .spec.kubernetes.controlPlane "taints" }}
        kubernetes_taints:
          {{ .spec.kubernetes.controlPlane.taints | toYaml | indent 10 | trim }}
        {{- end }}
        {{- if index $.spec.kubernetes.controlPlane "labels" }}
        kubernetes_node_labels:
          {{ $.spec.kubernetes.controlPlane.labels | toYaml | indent 10 | trim }}
        {{- end }}
        {{- if index $.spec.kubernetes.controlPlane "annotations" }}
        kubernetes_node_annotations:
          {{ $.spec.kubernetes.controlPlane.annotations | toYaml | indent 12 | trim }}
        {{- end }}
        {{- if index .spec.kubernetes.controlPlane "kubeletConfiguration" }}
          {{- range $key, $value := .spec.kubernetes.controlPlane.kubeletConfiguration }}
            {{- if kindIs "slice" $value }}
        kubelet_config_{{ $key | snakecase }}:
              {{- range $value }}
          - {{ . }}
              {{- end }}
            {{- else if kindIs "map" $value }}
        kubelet_config_{{ $key | snakecase }}:
              {{- range $subKey, $subValue := $value }}
          {{ $subKey }}: {{ $subValue }}
              {{- end }}
            {{- else }}
        kubelet_config_{{ $key | snakecase }}: {{ $value | quote }}
            {{- end }}
          {{- end }}
        {{- end }}
        {{- if and (index .spec.kubernetes "advanced") (index .spec.kubernetes.advanced "cloud") }}
          {{- if index .spec.kubernetes.advanced.cloud "provider" }}
        kubernetes_cloud_provider: "{{ .spec.kubernetes.advanced.cloud.provider }}"
          {{- end }}
          {{- if index .spec.kubernetes.advanced.cloud "config" }}
        kubernetes_cloud_config: "{{ .spec.kubernetes.advanced.cloud.config }}"
          {{- end }}
        {{- end }}

        {{- if and (index .spec.kubernetes "advanced") (index .spec.kubernetes.advanced "users") }}
          {{- if index .spec.kubernetes.advanced.users "names" }}
        kubernetes_users_names:
{{ .spec.kubernetes.advanced.users.names | toYaml | indent 10 }}
          {{- end }}
          {{- if index .spec.kubernetes.advanced.users "org" }}
        kubernetes_users_org: "{{ .spec.kubernetes.advanced.users.org }}"
          {{- end }}
        {{- end }}

        {{- if and (index .spec.kubernetes "advanced") (index .spec.kubernetes.advanced "oidc") }}
          {{- if index .spec.kubernetes.advanced.oidc "issuer_url" }}
        oidc_issuer_url: "{{ .spec.kubernetes.advanced.oidc.issuer_url }}"
          {{- end }}
          {{- if index .spec.kubernetes.advanced.oidc "client_id" }}
        oidc_client_id: "{{ .spec.kubernetes.advanced.oidc.client_id }}"
          {{- end }}
          {{- if index .spec.kubernetes.advanced.oidc "ca_file" }}
        oidc_ca_file: "{{ .spec.kubernetes.advanced.oidc.ca_file }}"
          {{- end }}

          {{- if index .spec.kubernetes.advanced.oidc "username_claim" }}
        oidc_username_claim: "{{ .spec.kubernetes.advanced.oidc.username_claim }}"
          {{- end }}
          {{- if index .spec.kubernetes.advanced.oidc "username_prefix" }}
        oidc_username_prefix: "{{ .spec.kubernetes.advanced.oidc.username_prefix }}"
          {{- end }}
          {{- if index .spec.kubernetes.advanced.oidc "groups_claim" }}
        oidc_groups_claim: "{{ .spec.kubernetes.advanced.oidc.groups_claim }}"
          {{- end }}
          {{- if index .spec.kubernetes.advanced.oidc "group_prefix" }}
        oidc_group_prefix: "{{ .spec.kubernetes.advanced.oidc.group_prefix }}"
          {{- end }}
        {{- end }}

        {{- if index .spec.kubernetes "advanced" }}

          {{- if index .spec.kubernetes.advanced "eventRateLimits" }}
        eventratelimits:
            {{- range .spec.kubernetes.advanced.eventRateLimits }}
          - type: {{ .type }}
            qps: {{ .qps }}
            burst: {{ .burst }}
              {{- if index . "cacheSize" }}
            cacheSize: {{ .cacheSize }}
              {{- end }}
            {{- end }}
          {{- end }}

          {{- if and (index .spec.kubernetes.advanced "controllerManager") (index .spec.kubernetes.advanced.controllerManager "gcThreshold") }}
        terminated_pod_gc_threshold: {{ .spec.kubernetes.advanced.controllerManager.gcThreshold }}
          {{- end }}

        {{- end }}

        {{- if  (.spec.kubernetes | digAny "advanced" "apiServer" "certSANs" false) }}
        kubernetes_apiserver_certSANs:
{{ .spec.kubernetes.advanced.apiServer.certSANs | toYaml | indent 10 }}
        {{- end }}
    etcd:
      hosts:
        {{- if not $etcdOnControlPlane }}
          {{- range $h := $etcdMembers }}
        {{ $h.hostname }}:
          {{- end }}
        {{- end }}
    nodes:
      children:
        {{- range $n := .spec.kubernetes.nodeGroups }}
        {{ $n.name }}:
          hosts:
          {{- range $h := $n.nodes }}
            {{ $h.hostname }}:
          {{- end }}
          vars:
            kubernetes_role: "{{ $n.name }}"
            kubernetes_control_plane_address: "{{ $controlPlaneAddress }}"
            {{- if index $n "taints" }}
            kubernetes_taints:
              {{ $n.taints | toYaml | indent 14 | trim }}
            {{- end }}
            {{- if index $n "labels" }}
            kubernetes_node_labels:
              {{ $n.labels | toYaml | indent 14 | trim }}
            {{- end -}}
            {{- if index $n "annotations" }}
            kubernetes_node_annotations:
              {{ $n.annotations | toYaml | indent 14 | trim }}
            {{- end -}}
            {{- if index $n "kubeletConfiguration" }}
              {{- range $key, $value := $n.kubeletConfiguration }}
                {{- if kindIs "slice" $value }}
            kubelet_config_{{ $key | snakecase }}:
                  {{- range $value }}
              - {{ . }}
                  {{- end }}
                {{- else if kindIs "map" $value }}
            kubelet_config_{{ $key | snakecase }}:
                  {{- range $subKey, $subValue := $value }}
              {{ $subKey }}: {{ $subValue }}
                  {{- end }}
                {{- else }}
            kubelet_config_{{ $key | snakecase }}: {{ $value | quote }}
                {{- end }}
              {{- end }}
            {{- end }}
            {{- if index $n "kernelParameters" }}
            kernel_parameters:
              {{ $n.kernelParameters | toYaml | indent 14 | trim }}
            {{- end -}}
      {{- end }}
  vars:
    {{- if and (index .spec.kubernetes "advancedAnsible") (index .spec.kubernetes.advancedAnsible "pythonInterpreter") }}
    ansible_python_interpreter: "{{ .spec.kubernetes.advancedAnsible.pythonInterpreter }}"
    {{- else }}
    ansible_python_interpreter: python3
    {{- end }}
    ansible_ssh_private_key_file: "{{ .spec.infrastructure.ssh.privateKeyPath }}"
    ansible_user: "{{ .spec.infrastructure.ssh.username }}"
    kubernetes_control_plane_address: "{{ $controlPlaneAddress }}"
    kubernetes_kubeconfig_path: ./
    kubernetes_version: "{{ .kubernetes.version }}"
    kubernetes_local_pki_dir: "{{ .spec.kubernetes.pkiPath }}/master"
    {{- if (.spec.kubernetes | digAny "advanced" "registry" false) }}
    kubernetes_image_registry: "{{ .spec.kubernetes.advanced.registry }}"
    {{- end }}
    {{- /* We assume that kubeProxy is enabled by default */}}
    {{- /* The `digAny` condition needs to be specified exactly as written below to properly check if the field has been populated */}}
    {{- if not (.spec | digAny "kubernetes" "advanced" "kubeProxy" "enabled" true) }}
    kubeadm_skip_phases:
      - "addon/kube-proxy"
    {{- end }}
    etcd_on_control_plane: {{ $etcdOnControlPlane }}
    etcd_initial_cluster: {{ $etcdInitialCluster | join "," }}
    etcd_endpoints:
{{ $etcdEndpoints | toYaml | indent 4 }}
    etcd_pki_local_dir: "{{ .spec.kubernetes.pkiPath }}/etcd"
    {{- if (index .spec.infrastructure "proxy") }}
    http_proxy: "{{ .spec.infrastructure.proxy | digAny "http" "" }}"
    https_proxy: "{{ .spec.infrastructure.proxy | digAny "https" "" }}"
    no_proxy: "{{ .spec.infrastructure.proxy | digAny "noProxy" "" }}"
    {{- end }}

    {{- if (index .spec.kubernetes "advanced") }}

    {{- if (index .spec.kubernetes.advanced "containerd") }}
    {{- if (index .spec.kubernetes.advanced.containerd "registryConfigs") }}
    containerd_registry_configs:
      {{- range $rc := .spec.kubernetes.advanced.containerd.registryConfigs }}
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
{{ $rc.mirrorEndpoint | toYaml | indent 10 }}
        {{- end }}
      {{- end }}
    {{- end }}
    {{- if hasKeyAny .spec.kubernetes.advanced.containerd "selfmanagedRepositories" }}
    containerd_self_managed_repositories: {{ .spec.kubernetes.advanced.containerd.selfmanagedRepositories }}
    {{- end }}
    {{- if hasKeyAny .spec.kubernetes.advanced.containerd "storageDir" }}
    containerd_storage_dir: "{{ .spec.kubernetes.advanced.containerd.storageDir }}"
    {{- end }}
    {{- if hasKeyAny .spec.kubernetes.advanced.containerd "stateDir" }}
    containerd_state_dir: "{{ .spec.kubernetes.advanced.containerd.stateDir }}"
    {{- end }}
    {{- if hasKeyAny .spec.kubernetes.advanced.containerd "systemdDir" }}
    containerd_systemd_dir: "{{ .spec.kubernetes.advanced.containerd.systemdDir }}"
    {{- end }}
    {{- if hasKeyAny .spec.kubernetes.advanced.containerd "oomScore" }}
    containerd_oom_score: {{ .spec.kubernetes.advanced.containerd.oomScore }}
    {{- end }}
    {{- if hasKeyAny .spec.kubernetes.advanced.containerd "grpcMaxRecvMessageSize" }}
    containerd_grpc_max_recv_message_size: {{ .spec.kubernetes.advanced.containerd.grpcMaxRecvMessageSize }}
    {{- end }}
    {{- if hasKeyAny .spec.kubernetes.advanced.containerd "grpcMaxSendMessageSize" }}
    containerd_grpc_max_send_message_size: {{ .spec.kubernetes.advanced.containerd.grpcMaxSendMessageSize }}
    {{- end }}
    {{- if hasKeyAny .spec.kubernetes.advanced.containerd "debugLevel" }}
    containerd_debug_level: "{{ .spec.kubernetes.advanced.containerd.debugLevel }}"
    {{- end }}
    {{- if hasKeyAny .spec.kubernetes.advanced.containerd "metricsAddress" }}
    containerd_metrics_address: "{{ .spec.kubernetes.advanced.containerd.metricsAddress }}"
    {{- end }}
    {{- if hasKeyAny .spec.kubernetes.advanced.containerd "metricsGrpcHistogram" }}
    containerd_metrics_grpc_histogram: {{ .spec.kubernetes.advanced.containerd.metricsGrpcHistogram }}
    {{- end }}
    {{- if hasKeyAny .spec.kubernetes.advanced.containerd "maxContainerLogLineSize" }}
    containerd_max_container_log_line_size: {{ .spec.kubernetes.advanced.containerd.maxContainerLogLineSize }}
    {{- end }}
    {{- if hasKeyAny .spec.kubernetes.advanced.containerd "deviceOwnershipFromSecurityContext" }}
    containerd_device_ownership_from_security_context: {{ .spec.kubernetes.advanced.containerd.deviceOwnershipFromSecurityContext }}
    {{- end }}
    {{- end }}

    {{- if (index .spec.kubernetes.advanced "encryption") }}
    {{- if (index .spec.kubernetes.advanced.encryption "tlsCipherSuites") }}
    tls_cipher_suites:
      {{- toYaml .spec.kubernetes.advanced.encryption.tlsCipherSuites | nindent 6 }}
    {{- end }}
    {{- if (index .spec.kubernetes.advanced.encryption "tlsCipherSuitesKubelet") }}
    kubelet_tls_cipher_suites:
      {{- toYaml .spec.kubernetes.advanced.encryption.tlsCipherSuitesKubelet | nindent 6 }}
    {{- end }}
    {{- if (index .spec.kubernetes.advanced.encryption "configuration") }}
    kubernetes_encryption_config: "./encryption-config.yaml"
    {{- end }}
    {{- end }}

    {{- range $key, $value := index .spec.kubernetes.advanced "kubeletConfiguration" }}
      {{- $keyStr := toString $key }}
      {{- if kindIs "slice" $value }}
    kubelet_config_{{ $keyStr | snakecase }}:
        {{- range $value }}
      - {{ . }}
        {{- end }}
      {{- else if kindIs "map" $value }}
    kubelet_config_{{ $keyStr | snakecase }}:
        {{- range $subKey, $subValue := $value }}
      {{ $subKey }}: {{ $subValue }}
        {{- end }}
      {{- else }}
    kubelet_config_{{ $keyStr | snakecase }}: {{ $value | quote }}
      {{- end }}
    {{- end }}

    {{- end }}
