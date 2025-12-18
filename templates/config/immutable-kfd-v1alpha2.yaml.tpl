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
      keyPath: ~/.ssh/id_rsa

    # iPXE server for network boot
    ipxeServer:
      url: https://ipxe.example.com:8080

    # Nodes configuration (minimum 1 node for testing)
    nodes:
      - hostname: node01.example.com
        macAddress: "52:54:00:00:00:01"
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

  # Kubernetes cluster configuration
  kubernetes:
    # Control plane configuration
    controlPlane:
      address: k8s-api.example.com:6443
      members:
        - hostname: node01.example.com
          ip: 192.168.1.10

    # etcd configuration
    etcd:
      members:
        - hostname: node01.example.com
          ip: 192.168.1.10

    # Networking configuration
    networking:
      podCIDR: 10.244.0.0/16
      serviceCIDR: 10.96.0.0/12

  # Fury Kubernetes Distribution modules
  distribution:
    common:
      # Node selector for common components
      nodeSelector: {}

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
        type: kyverno

      dr:
        type: on-premises

      auth:
        provider:
          type: none
