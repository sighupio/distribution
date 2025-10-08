{{- $dnsZone := .spec.kubernetes.dnsZone -}}
{{- $controlPlaneAddress := .spec.kubernetes.controlPlaneAddress -}}

all:
  children:
    {{- if .spec.kubernetes.loadBalancers.enabled }}
    haproxy:
      hosts:
        {{- range $h := .spec.kubernetes.loadBalancers.hosts }}
        {{ $h.name }}:
          ansible_host: "{{ $h.ip }}"
          kubernetes_hostname: "{{ $h.name }}.{{ $dnsZone }}"
        {{- end }}
      vars:
        keepalived_cluster: {{ .spec.kubernetes.loadBalancers.keepalived.enabled }}
        keepalived_interface: "{{ .spec.kubernetes.loadBalancers.keepalived.interface }}"
        keepalived_ip: "{{ .spec.kubernetes.loadBalancers.keepalived.ip }}"
        keepalived_virtual_router_id: "{{ .spec.kubernetes.loadBalancers.keepalived.virtualRouterId }}"
        keepalived_passphrase: "{{ .spec.kubernetes.loadBalancers.keepalived.passphrase }}"
        {{- if hasKeyAny .spec.kubernetes.loadBalancers "selfmanagedRepositories" }}
        haproxy_self_managed_repositories: {{ .spec.kubernetes.loadBalancers.selfmanagedRepositories }}
        {{- end }}
    {{- end }}
    master:
      hosts:
        {{- $etcdInitialCluster := list }}
        {{- range $h := .spec.kubernetes.masters.hosts }}
        {{- if not (index $.spec.kubernetes "etcd") }}
        {{- $etcdUri := print $h.name "=https://" $h.name "." $dnsZone ":2380" }}
        {{- $etcdInitialCluster = append $etcdInitialCluster $etcdUri }}
        {{- end }}
        {{ $h.name }}:
          ansible_host: "{{ $h.ip }}"
          kubernetes_apiserver_advertise_address: "{{ $h.ip }}"
          kubernetes_hostname: "{{ $h.name }}.{{ $dnsZone }}"
          {{- if index $.spec.kubernetes.masters "labels" }}
          kubernetes_node_labels:
            {{ $.spec.kubernetes.masters.labels | toYaml | indent 12 | trim }}
          {{- end }}
          {{- if index $.spec.kubernetes.masters "annotations" }}
          kubernetes_node_annotations:
            {{ $.spec.kubernetes.masters.annotations | toYaml | indent 12 | trim }}
          {{- end }}
        {{- end }}
      vars:
        dns_zone: "{{ $dnsZone }}"
        kubernetes_cluster_name: "{{ .metadata.name }}"
        kubernetes_control_plane_address: "{{ $controlPlaneAddress }}"
        kubernetes_pod_cidr: "{{ .spec.kubernetes.podCidr }}"
        kubernetes_svc_cidr: "{{ .spec.kubernetes.svcCidr }}"
        {{- if not (index $.spec.kubernetes "etcd") }}
        etcd_initial_cluster: "{{ $etcdInitialCluster | join "," }}"
        {{- else }}
        etcd:
          endpoints:
            {{- range $h := .spec.kubernetes.etcd.hosts }}
            - "https://{{ $h.name }}.{{ $dnsZone }}:2379"
            {{- end }}
          caFile: "/etc/etcd/pki/etcd/ca.crt"
          keyFile: "/etc/etcd/pki/apiserver-etcd-client.key"
          certFile: "/etc/etcd/pki/apiserver-etcd-client.crt"
        {{- end }}
        {{- if index .spec.kubernetes.masters "kubeletConfiguration" }}
          {{- range $key, $value := .spec.kubernetes.masters.kubeletConfiguration }}
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
        {{- if index .spec.kubernetes.masters "kernelParameters" }}
        kernel_parameters:
          {{ .spec.kubernetes.masters.kernelParameters | toYaml | indent 10 | trim }}
        {{- end -}}
        {{- if hasKeyAny .spec.kubernetes.masters "taints" }}
        kubernetes_taints:
          {{ .spec.kubernetes.masters.taints | toYaml | indent 10 | trim }}
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
        {{- if and (index .spec.kubernetes.advanced "registry") (ne .spec.kubernetes.advanced.registry "") }}
        kubernetes_image_registry: "{{ .spec.kubernetes.advanced.registry }}"
        {{- end }}

        {{- if index .spec.kubernetes.advanced "eventRateLimits" }}
        eventratelimits:
          {{- range .spec.kubernetes.advanced.eventRateLimits }}
          - type: {{ .type }}
            qps: {{ .qps }}
            burst: {{ .burst }}
            {{- if .cacheSize }}
            cacheSize: {{ .cacheSize }}
            {{- end }}
          {{- end }}
        {{- end }}

        {{- if and (index .spec.kubernetes.advanced "controllerManager") (index .spec.kubernetes.advanced.controllerManager "gcThreshold") }}
        terminated_pod_gc_threshold: {{ .spec.kubernetes.advanced.controllerManager.gcThreshold }}
        {{- end }}

        {{- end }}

        {{- if and (index .spec.kubernetes "advanced") (index .spec.kubernetes.advanced "apiServerCertSANs") }}
        kubernetes_apiserver_certSANs:
{{ .spec.kubernetes.advanced.apiServerCertSANs | toYaml | indent 10 }}
        {{- end }}
        {{- if and (hasKeyAny .spec.kubernetes "advanced") (hasKeyAny .spec.kubernetes.advanced "kubeProxy") (not (index .spec.kubernetes.advanced.kubeProxy "enabled")) }}
        kubeadm_skip_phases:
          - "addon/kube-proxy"
        {{- end }}
    etcd:
      hosts:
        {{- if index $.spec.kubernetes "etcd" }}
        {{- range $h := .spec.kubernetes.etcd.hosts }}
        {{- $etcdUri := print $h.name "=https://" $h.name "." $dnsZone ":2380" }}
        {{- $etcdInitialCluster = append $etcdInitialCluster $etcdUri }}
        {{ $h.name }}:
          ansible_host: "{{ $h.ip }}"
          kubernetes_hostname: "{{ $h.name }}.{{ $dnsZone }}"
          etcd_client_address: "{{ $h.ip }}"
        {{- end }}
      vars:
        dns_zone: "{{ $dnsZone }}"
        etcd_initial_cluster: "{{ $etcdInitialCluster | join "," }}"
        {{- else }}
        {{- range $h := .spec.kubernetes.masters.hosts }}
        {{ $h.name }}:
          ansible_host: "{{ $h.ip }}"
          kubernetes_hostname: "{{ $h.name }}.{{ $dnsZone }}"
        {{- end }}
      vars:
        dns_zone: "{{ $dnsZone }}"
        {{- end }}
    nodes:
      children:
        {{- range $n := .spec.kubernetes.nodes }}
        {{ $n.name }}:
          hosts:
          {{- range $h := $n.hosts }}
            {{ $h.name }}:
              ansible_host: "{{ $h.ip }}"
              kubernetes_hostname: "{{ $h.name }}.{{ $dnsZone }}"
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
    ungrouped: {}
  vars:
    {{- if and (index .spec.kubernetes "advancedAnsible") (index .spec.kubernetes.advancedAnsible "pythonInterpreter") }}
    ansible_python_interpreter: "{{ .spec.kubernetes.advancedAnsible.pythonInterpreter }}"
    {{- else }}
    ansible_python_interpreter: python3
    {{- end }}
    ansible_ssh_private_key_file: "{{ .spec.kubernetes.ssh.keyPath }}"
    ansible_user: "{{ .spec.kubernetes.ssh.username }}"
    kubernetes_kubeconfig_path: ./
    kubernetes_version: "{{ .kubernetes.version }}"
    {{- if not (index $.spec.kubernetes "etcd") }}
    etcd_on_control_plane: true
    {{- else }}
    etcd_on_control_plane: false
    {{- end }}
    {{- if (index .spec.kubernetes "proxy") }}
    http_proxy: "{{ .spec.kubernetes.proxy.http }}"
    https_proxy: "{{ .spec.kubernetes.proxy.https }}"
    no_proxy: "{{ .spec.kubernetes.proxy.noProxy }}"
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

    {{- if index .spec.kubernetes.advanced "airGap" }}
    {{- if index .spec.kubernetes.advanced.airGap "containerdDownloadUrl" }}
    containerd_download_url: "{{ .spec.kubernetes.advanced.airGap.containerdDownloadUrl }}"
    {{- end }}
    {{- if index .spec.kubernetes.advanced.airGap "runcDownloadUrl" }}
    runc_download_url: "{{ .spec.kubernetes.advanced.airGap.runcDownloadUrl }}"
    {{- end }}
    {{- if index .spec.kubernetes.advanced.airGap "runcChecksum" }}
    runc_checksum: "{{ .spec.kubernetes.advanced.airGap.runcChecksum }}"
    {{- end }}
    {{- if index .spec.kubernetes.advanced.airGap "dependenciesOverride" }}
    dependencies_override:
      {{- .spec.kubernetes.advanced.airGap.dependenciesOverride | toYaml | nindent 6 }}
    {{- end }}
    {{- if index .spec.kubernetes.advanced.airGap "etcdDownloadUrl" }}
    etcd_download_url: "{{ .spec.kubernetes.advanced.airGap.etcdDownloadUrl }}"
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
    {{- if index .spec.kubernetes.advanced "kernelParameters" }}
    kernel_parameters:
      {{ .spec.kubernetes.advanced.kernelParameters | toYaml | indent 6 | trim }}
    {{- end -}}

    {{- if hasKeyAny .spec.kubernetes.advanced "selfmanagedRepositories" }}
    kubernetes_self_managed_repositories: {{ .spec.kubernetes.advanced.selfmanagedRepositories }}
    {{- end }}

    {{- end }}
