# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

output "haproxy_ip" {
  value = hcloud_server.haproxy.ipv4_address
}

output "ingress_domain" {
  value = "ingress.${replace(hcloud_server.haproxy.ipv4_address, ".", "-")}.nip.io"
}

output "furyctl_yaml" {
  value = <<EOF
---
apiVersion: kfd.sighup.io/v1alpha2
kind: OnPremises
metadata:
  name: reevo
spec:
  distributionVersion: v1.31.1
  kubernetes:
    pkiFolder: ./pki
    ssh:
      username: root
      keyPath: /cache/ci-ssh-key
    dnsZone: nip.io
    controlPlaneAddress: ${replace(hcloud_server.haproxy.ipv4_address, ".", "-")}.nip.io:6443
    podCidr: 10.128.0.0/14
    svcCidr: 172.30.0.0/16
    loadBalancers:
      enabled: true
      hosts:
        - name: haproxy-10-10-1-2
          ip: 10.10.1.2
      keepalived:
        enabled: false
        interface: enp0s6
        ip: 10.250.250.179/32
        virtualRouterId: "201"
        passphrase: "b16cf069"
      stats:
        username: admin
        password: "password"
      additionalConfig: "{file://./haproxy-additional.cfg}"
    masters:
      hosts:
        - name: controlplane0-10-10-1-3
          ip: 10.10.1.3
        - name: controlplane1-10-10-1-4
          ip: 10.10.1.4
        - name: controlplane2-10-10-1-5
          ip: 10.10.1.5
    nodes:
      - name: infra
        hosts:
          - name: infra0-10-10-1-6
            ip: 10.10.1.6
          - name: infra1-10-10-1-7
            ip: 10.10.1.7
          - name: infra2-10-10-1-8
            ip: 10.10.1.8
        taints: []
      - name: worker
        hosts:
          - name: worker0-10-10-1-9
            ip: 10.10.1.9
          - name: worker1-10-10-1-10
            ip: 10.10.1.10
        taints: []
    #advancedAnsible:
      #config: |
      #  ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q root@${hcloud_server.haproxy.ipv4_address}"'
    advanced: 
      encryption:
        configuration: "{file://./encrypted-secret-config.yaml}"
  distribution:
    common:
      nodeSelector:
         node.kubernetes.io/role: infra
      #tolerations:
      #  - effect: NoSchedule
      #    key: node.kubernetes.io/role
      #    value: infra
      networkPoliciesEnabled: true
    modules:
      networking:
        type: calico
      ingress:
        baseDomain: ingress.${replace(hcloud_server.haproxy.ipv4_address, ".", "-")}.nip.io
        nginx:
          type: single
          tls:
            provider: secret
            secret:
              cert: "{file://tls.crt}"
              key: "{file://tls.key}"
              ca: "{file://ca.crt}"
        certManager:
          clusterIssuer:
            name: letsencrypt-fury
            email: samuele.chiocca@reevo.it
            type: http01
      logging: 
        type: loki
        opensearch:
          type: triple
        loki: 
          backend: minio
          tsdbStartDate: "2024-11-18"
      monitoring:
        type: mimir
        mimir: 
          retentionTime: 3d
          backend: minio
        prometheus:
          retentionTime: 1d
          retentionSize: 5GiB
          storageSize: 20Gi
        alertmanager:
          installDefaultRules: false
      policy: 
        type: gatekeeper
        gatekeeper:
          enforcementAction: warn
          installDefaultPolicies: true 
      dr:
        type: on-premises
        velero: 
          backend: minio
          schedules:
            install: true
            definitions:
              full:
                snapshotMoveData: true
          snapshotController:
            install: true
      tracing: 
        type: tempo
        tempo: 
          backend: minio
      auth:
        provider:
          type: none


  plugins:
    helm:
      repositories:
        - name: longhorn
          url: https://charts.longhorn.io
      releases:
        - name: longhorn
          namespace: longhorn-system
          chart: longhorn/longhorn
          version: '1.8.1'
          set:
            - name: persistence.defaultClassReplicaCount
              value: "2"
EOF
}

output "furyctl_upgrade_yaml" {
  value = <<EOF
---
apiVersion: kfd.sighup.io/v1alpha2
kind: OnPremises
metadata:
  name: reevo
spec:
  distributionVersion: v1.32.1
  kubernetes:
    pkiFolder: ./pki
    ssh:
      username: root
      keyPath: /cache/ci-ssh-key
    dnsZone: nip.io
    controlPlaneAddress: ${replace(hcloud_server.haproxy.ipv4_address, ".", "-")}.nip.io:6443
    podCidr: 10.128.0.0/14
    svcCidr: 172.30.0.0/16
    loadBalancers:
      enabled: true
      hosts:
        - name: haproxy-10-10-1-2
          ip: 10.10.1.2
      keepalived:
        enabled: false
        interface: enp0s6
        ip: 10.250.250.179/32
        virtualRouterId: "201"
        passphrase: "b16cf069"
      stats:
        username: admin
        password: "password"
      additionalConfig: "{file://./haproxy-additional.cfg}"
    masters:
      hosts:
        - name: controlplane0-10-10-1-3
          ip: 10.10.1.3
        - name: controlplane1-10-10-1-4
          ip: 10.10.1.4
        - name: controlplane2-10-10-1-5
          ip: 10.10.1.5
    nodes:
      - name: infra
        hosts:
          - name: infra0-10-10-1-6
            ip: 10.10.1.6
          - name: infra1-10-10-1-7
            ip: 10.10.1.7
          - name: infra2-10-10-1-8
            ip: 10.10.1.8
        taints: []
      - name: worker
        hosts:
          - name: worker0-10-10-1-9
            ip: 10.10.1.9
          - name: worker1-10-10-1-10
            ip: 10.10.1.10
        taints: []
    #advancedAnsible:
      #config: |
      #  ansible_ssh_common_args='-o ProxyCommand="ssh -W %h:%p -q root@${hcloud_server.haproxy.ipv4_address}"'
    advanced: 
      encryption:
        configuration: "{file://./encrypted-secret-config.yaml}"
  distribution:
    common:
      nodeSelector:
         node.kubernetes.io/role: infra
      #tolerations:
      #  - effect: NoSchedule
      #    key: node.kubernetes.io/role
      #    value: infra
      networkPoliciesEnabled: true
    modules:
      networking:
        type: calico
      ingress:
        baseDomain: ingress.${replace(hcloud_server.haproxy.ipv4_address, ".", "-")}.nip.io
        nginx:
          type: single
          tls:
            provider: secret
            secret:
              cert: "{file://tls.crt}"
              key: "{file://tls.key}"
              ca: "{file://ca.crt}"
        certManager:
          clusterIssuer:
            name: letsencrypt-fury
            email: samuele.chiocca@reevo.it
            type: http01
      logging: 
        type: loki
        opensearch:
          type: triple
        loki: 
          backend: minio
          tsdbStartDate: "2024-11-18"
      monitoring:
        type: mimir
        mimir: 
          retentionTime: 3d
          backend: minio
        prometheus:
          retentionTime: 1d
          retentionSize: 5GiB
          storageSize: 20Gi
        alertmanager:
          installDefaultRules: false
      policy: 
        type: gatekeeper
        gatekeeper:
          enforcementAction: warn
          installDefaultPolicies: true 
      dr:
        type: on-premises
        velero: 
          backend: minio
          schedules:
            install: true
            definitions:
              full:
                snapshotMoveData: true
          snapshotController:
            install: true
      tracing: 
        type: tempo
        tempo: 
          backend: minio
      auth:
        provider:
          type: none


  plugins:
    helm:
      repositories:
        - name: longhorn
          url: https://charts.longhorn.io
      releases:
        - name: longhorn
          namespace: longhorn-system
          chart: longhorn/longhorn
          version: '1.8.1'
          set:
            - name: persistence.defaultClassReplicaCount
              value: "1"
EOF
}

output "req_dns" {
  value = <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = ingress.${replace(hcloud_server.haproxy.ipv4_address, ".", "-")}.nip.io
DNS.2 = *.ingress.${replace(hcloud_server.haproxy.ipv4_address, ".", "-")}.nip.io
EOF
}