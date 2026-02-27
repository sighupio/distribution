# yaml-language-server: $schema=https://raw.githubusercontent.com/sighupio/distribution/{{.DistributionVersion}}/schemas/public/immutable-kfd-v1alpha2.json
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.


# This is a sample configuration file to be used as a starting point. For the
# complete reference of the configuration file schema, please refer to the
# official documentation:
# https://docs.sighup.io/docs/installation/sd-configuration/providers/Immutable

---
apiVersion: kfd.sighup.io/v1alpha2
kind: Immutable
metadata:
  # The name of the cluster
  name: {{.Name}}
spec:
  # Defines which KFD version will be installed
  distributionVersion: {{.DistributionVersion}}

  # Infrastructure phase configuration (SSH, , iPXE, Nodes and Load Balancers)
  infrastructure:
    # SSH configuration for node access and configuration
    ssh:
      username: core
      privateKeyPath: ~/.ssh/id_rsa
      # publicKeyPath: ~/.ssh/id_rsa.pub
      # If publicKeyPath is not specified defaults to the private key path with .pub extension

    # furyctl can act as the iPXE server for network booting of the nodes.
    # Set this URL to the address of the machine where furyctl will run on
    ipxeServer:
      url: https://ipxe.example.com:8080

    # Nodes (machines) configuration
    nodes:
      - hostname: lb1.example.com
        macAddress: "52:54:00:00:00:01" # MAC address is used for iPXE booting and inventory generation
        # arch: x86-64  # Optional: CPU architecture (x86-64|arm64). Default: x86-64.
        storage:
          installDisk: /dev/sda
        network:
          ethernets:
            eth0:
              # Here we are setting a static IP configuration, see lb2 for a DHCP example.
              addresses:
                - 192.168.1.200/24
              gateway: 192.168.1.1
              nameservers:
                addresses:
                  - 8.8.8.8
                  - 8.8.4.4

      - hostname: lb2.example.com
        macAddress: "52:54:00:00:00:02"
        storage:
          installDisk: /dev/sda
        network:
          ethernets:
            eth0:
              # DHCP configuration example, see lb1 for a static IP example.
              dhcp4: true

      # Control Plane Nodes
      - hostname: cp1.example.com
        macAddress: "52:54:00:01:00:01"
        # arch: x86-64  # Optional: Each node can have different arch for mixed clusters
        storage:
          installDisk: /dev/sda
        network:
          ethernets:
            eth0:
              addresses:
                - 192.168.1.10/24
              gateway: 192.168.1.1
              nameservers:
                addresses:
                  - 8.8.8.8
                  - 8.8.4.4

      - hostname: cp2.example.com
        macAddress: "52:54:00:01:00:02"
        storage:
          installDisk: /dev/sda
        network:
          ethernets:
            eth0:
              addresses:
                - 192.168.1.11/24
              gateway: 192.168.1.1
              nameservers:
                addresses:
                  - 8.8.8.8
                  - 8.8.4.4

      - hostname: cp3.example.com
        macAddress: "52:54:00:01:00:03"
        storage:
          installDisk: /dev/sda
        network:
          ethernets:
            eth0:
              addresses:
                - 192.168.1.12/24
              gateway: 192.168.1.1
              nameservers:
                addresses:
                  - 8.8.8.8
                  - 8.8.4.4

      # Infrastructure Worker Nodes
      - hostname: infra1.example.com
        macAddress: "52:54:00:02:00:01"
        # arch: arm64  # Example: ARM64 node in mixed-architecture cluster
        storage:
          installDisk: /dev/sda
        network:
          ethernets:
            eth0:
              addresses:
                - 192.168.1.100/24
              gateway: 192.168.1.1
              nameservers:
                addresses:
                  - 8.8.8.8
                  - 8.8.4.4

      - hostname: infra2.example.com
        macAddress: "52:54:00:02:00:02"
        storage:
          installDisk: /dev/sda
        network:
          ethernets:
            eth0:
              addresses:
                - 192.168.1.101/24
              gateway: 192.168.1.1
              nameservers:
                addresses:
                  - 8.8.8.8
                  - 8.8.4.4

      - hostname: infra3.example.com
        macAddress: "52:54:00:02:00:03"
        storage:
          installDisk: /dev/sda
        network:
          ethernets:
            eth0:
              addresses:
                - 192.168.1.102/24
              gateway: 192.168.1.1
              nameservers:
                addresses:
                  - 8.8.8.8
                  - 8.8.4.4

      # Application Worker Nodes
      - hostname: worker1.example.com
        macAddress: "52:54:00:03:00:01"
        # arch: x86-64  # Optional: Specify per-node architecture
        storage:
          installDisk: /dev/sda
        network:
          ethernets:
            eth0:
              addresses:
                - 192.168.1.110/24
              gateway: 192.168.1.1
              nameservers:
                addresses:
                  - 8.8.8.8
                  - 8.8.4.4

      - hostname: worker2.example.com
        macAddress: "52:54:00:03:00:02"
        storage:
          installDisk: /dev/sda
        network:
          ethernets:
            eth0:
              addresses:
                - 192.168.1.111/24
              gateway: 192.168.1.1
              nameservers:
                addresses:
                  - 8.8.8.8
                  - 8.8.4.4

      - hostname: worker3.example.com
        macAddress: "52:54:00:03:00:03"
        storage:
          installDisk: /dev/sda
        network:
          ethernets:
            eth0:
              addresses:
                - 192.168.1.112/24
              gateway: 192.168.1.1
              nameservers:
                addresses:
                  - 8.8.8.8
                  - 8.8.4.4

    # Here we define the Load balancers configuration.
    # Load Balancers use an HAProxy container and (optional) Keepalived for VIP in HA
    loadBalancers:
      # Members defines the nodes that will be part of the load balancer pool.
      members:
        - hostname: lb1.example.com
        - hostname: lb2.example.com
      keepalived:
        enabled: true
        interface: eth0
        ip: 192.168.1.201
        # virtualRouterID is optional, if you have more than one keepalived cluster in the same network, make sure to use different virtualRouterId for each cluster
        virtualRouterId: "1"

  # Kubernetes cluster configuration
  kubernetes:
    # Kubernetes Cluster basic networking configuration independent of the CNI.
    # More advanced configuration can be defined in the distribution.modules.networking section
    networking:
      podCIDR: 10.244.0.0/16
      serviceCIDR: 10.96.0.0/12
    # Control plane configuration (3 cps for HA)
    controlPlane:
      # The address points to the load balancer VIP for HA
      address: api.example.com:6443
      # Which nodes will be used for the control plane, they should match the hostnames defined in the infrastructure.nodes section
      members:
        - hostname: cp1.example.com
        - hostname: cp2.example.com
        - hostname: cp3.example.com

    # (optional) dedicated etcd nodes configuration
    # If etcd members are set, they will be used instead of the control plane members for etcd configuration.
    # This allows for external etcd clusters or different topologies.
    # etcd:
    #   members:
    #     - hostname: etcd1.example.com
    #     - hostname: etcd2.example.com
    #     - hostname: etcd3.example.com

    # Worker nodes organized in node groups
    nodeGroups:
      # Infrastructure workers (for system components)
      - name: infra
        # Select the nodes that will be part of this node group, they should match the hostnames defined in the infrastructure.nodes section
        nodes:
          - hostname: infra1.example.com
          - hostname: infra2.example.com
          - hostname: infra3.example.com
      # Application workers (for user workloads)
      - name: workers
        nodes:
          - hostname: worker1.example.com
          - hostname: worker2.example.com
          - hostname: worker3.example.com
    # Specify advanced configuration for Kubernetes features, such as encryption, additional users, kube-proxy, etc.
    advanced:
      encryption:
        configuration: "{file://./secrets/etcd-encryption-config.yaml}"
      kubeProxy:
        enabled: true

  # SIGHUP Distribution modules
  distribution:
    common:
      # Node selector for common components, for example deploy to infra nodes
      nodeSelector:
        node-role.kubernetes.io/infra: ""
      # Tolerations to allow scheduling on infra nodes
      tolerations:
        - key: node-role.kubernetes.io/infra
          operator: Exists
          effect: NoSchedule

    modules:
      networking:
        type: cilium

      ingress:
        baseDomain: example.com
        haproxy:
          type: single
        certManager:
          clusterIssuer:
            name: letsencrypt-prod
            email: admin@example.com
            type: http01

      logging:
        type: loki

      monitoring:
        type: prometheus

      policy:
        type: none

      dr:
        type: none

      auth:
        provider:
          type: none
