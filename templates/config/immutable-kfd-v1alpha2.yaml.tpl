# yaml-language-server: $schema=https://raw.githubusercontent.com/sighupio/distribution/{{.DistributionVersion}}/schemas/public/immutable-kfd-v1alpha2.json
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# This is a sample configuration file to be used as a starting point. For the
# complete reference of the configuration file schema, please refer to the
# official documentation:
# https://docs.kubernetesfury.com/docs/installation/kfd-configuration/providers/Immutable

---
apiVersion: kfd.sighup.io/v1alpha2
kind: Immutable
metadata:
  # The name of the cluster
  name: {{.Name}}
spec:
  # Defines which KFD version will be installed
  distributionVersion: {{.DistributionVersion}}

  # Infrastructure configuration for bare-metal nodes
  infrastructure:
    # SSH configuration for node access
    ssh:
      username: core
      privateKeyPath: ~/.ssh/id_rsa
      # publicKeyPath: ~/.ssh/id_rsa.pub  # Optional: auto-derived if not specified

    # iPXE server for network boot
    ipxeServer:
      url: https://ipxe.example.com:8080

    # Load balancers (HAProxy) with Keepalived for VIP HA
    loadBalancers:
      enabled: true
      members:
        - hostname: haproxy1.example.com
          ip: 192.168.1.200
        - hostname: haproxy2.example.com
          ip: 192.168.1.202
      keepalived:
        enabled: true
        interface: eth0
        ip: 192.168.1.201
        virtualRouterId: "1"

    # Nodes configuration (11 nodes: 2 load balancers + 3 control plane + 3 infra workers + 3 app workers)
    nodes:
      # Load Balancer Nodes (HAProxy + Keepalived for HA)
      - hostname: haproxy1.example.com
        macAddress: "52:54:00:00:00:01"
        # arch: x86-64  # Optional: CPU architecture (x86-64|arm64). Default: x86-64. See examples/immutable-mixed-arch-example.yaml
        storage:
          installDisk: /dev/sda
        network:
          ethernets:
            eth0:
              addresses:
                - 192.168.1.200/24
              gateway: 192.168.1.1
              nameservers:
                addresses:
                  - 8.8.8.8
                  - 8.8.4.4

      - hostname: haproxy2.example.com
        macAddress: "52:54:00:00:00:02"
        storage:
          installDisk: /dev/sda
        network:
          ethernets:
            eth0:
              addresses:
                - 192.168.1.202/24
              gateway: 192.168.1.1
              nameservers:
                addresses:
                  - 8.8.8.8
                  - 8.8.4.4

      # Control Plane Nodes
      - hostname: master1.example.com
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

      - hostname: master2.example.com
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

      - hostname: master3.example.com
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

  # Kubernetes cluster configuration
  kubernetes:
    # Kubernetes version (matches immutable.yaml)
    version: "1.33.4"

    # Control plane configuration (3 masters for HA)
    # The address points to the load balancer VIP for HA
    controlPlane:
      address: 192.168.1.201:6443
      members:
        - hostname: master1.example.com
          ip: 192.168.1.10
        - hostname: master2.example.com
          ip: 192.168.1.11
        - hostname: master3.example.com
          ip: 192.168.1.12

    # etcd configuration (stacked on control plane)
    etcd:
      members:
        - hostname: master1.example.com
          ip: 192.168.1.10
        - hostname: master2.example.com
          ip: 192.168.1.11
        - hostname: master3.example.com
          ip: 192.168.1.12

    # Worker nodes organized in node groups
    nodeGroups:
      # Infrastructure workers (for system components)
      - name: infra
        nodes:
          - hostname: infra1.example.com
            ip: 192.168.1.100
          - hostname: infra2.example.com
            ip: 192.168.1.101
          - hostname: infra3.example.com
            ip: 192.168.1.102
      # Application workers (for user workloads)
      - name: workers
        nodes:
          - hostname: worker1.example.com
            ip: 192.168.1.110
          - hostname: worker2.example.com
            ip: 192.168.1.111
          - hostname: worker3.example.com
            ip: 192.168.1.112

    # Networking configuration
    networking:
      podCIDR: 10.244.0.0/16
      serviceCIDR: 10.96.0.0/12

  # Fury Kubernetes Distribution modules
  distribution:
    common:
      # Node selector for common components (deploy to infra nodes)
      nodeSelector:
        node-role.kubernetes.io/infra: ""
      # Tolerations to allow scheduling on infra nodes
      tolerations:
        - key: node-role.kubernetes.io/infra
          operator: Exists
          effect: NoSchedule

    modules:
      networking:
        type: calico

      ingress:
        baseDomain: example.com
        nginx:
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
