# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

output "nodes" {
  value = module.vms.nodes
}

output "ingress_domain" {
  value = "ingress.${module.vms.dash}-2.nip.io"
}

# kube-bench runs on one representative node per role (all control planes / all
# workers are configured identically), matching the original e2e.
output "controlplane_0_ip" {
  value = module.vms.controlplane_0_ip
}

output "worker_0_ip" {
  value = module.vms.worker_0_ip
}

# all node IPs, for the prepare-nodes playbook (open-iscsi on every host)
output "all_ips" {
  value = module.vms.all_ips
}

# Rendered furyctl.yaml for this run's subnet. controlPlaneAddress/ingress use the
# haproxy private IP via nip.io; node names embed their dashed IP so etcd peer URLs
# resolve through the nip.io dnsZone. Real VMs => longhorn (iSCSI) works.
output "furyctl_yaml" {
  value = <<EOF
---
apiVersion: kfd.sighup.io/v1alpha2
kind: OnPremises
metadata:
  name: reevo
spec:
  distributionVersion: v1.35.0
  kubernetes:
    pkiFolder: ./pki
    ssh:
      username: root
      keyPath: /cache/ci-ssh-key
    dnsZone: nip.io
    controlPlaneAddress: ${module.vms.dash}-2.nip.io:6443
    podCidr: 10.128.0.0/14
    svcCidr: 172.30.0.0/16
    loadBalancers:
      enabled: true
      selfmanagedRepositories: false
      hosts:
        - name: haproxy-${module.vms.dash}-2
          ip: ${module.vms.subnet}.2
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
        - name: controlplane0-${module.vms.dash}-3
          ip: ${module.vms.subnet}.3
        - name: controlplane1-${module.vms.dash}-4
          ip: ${module.vms.subnet}.4
        - name: controlplane2-${module.vms.dash}-5
          ip: ${module.vms.subnet}.5
    nodes:
      - name: infra
        hosts:
          - name: infra0-${module.vms.dash}-6
            ip: ${module.vms.subnet}.6
          - name: infra1-${module.vms.dash}-7
            ip: ${module.vms.subnet}.7
          - name: infra2-${module.vms.dash}-8
            ip: ${module.vms.subnet}.8
        taints: []
      - name: worker
        hosts:
          - name: worker0-${module.vms.dash}-9
            ip: ${module.vms.subnet}.9
        taints: []
    advanced:
      selfmanagedRepositories: false
      containerd:
        selfmanagedRepositories: false
      encryption:
        configuration: "{file://./encrypted-secret-config.yaml}"
  distribution:
    common:
      nodeSelector:
        node.kubernetes.io/role: infra
      networkPoliciesEnabled: true
    modules:
      networking:
        type: cilium
      ingress:
        baseDomain: ingress.${module.vms.dash}-2.nip.io
        nginx:
          type: single
          tls:
            provider: secret
            secret:
              cert: "{file://tls.crt}"
              key: "{file://tls.key}"
              ca: "{file://ca.crt}"
        haproxy:
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
        # prometheus instead of mimir: mimir-distributed (+ its minio) is too heavy
        # for a single-worker e2e -- minio + the distributed consumers can't come up
        # within kapp's deadlines. prometheus keeps monitoring coverage, far lighter.
        type: prometheus
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
        type: kyverno
        kyverno:
          additionalExcludedNamespaces: ["longhorn-system"]
          installDefaultPolicies: true
          validationFailureAction: Audit
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
        # none: tempo-distributed (+ its minio) is too heavy for a single-worker e2e.
        type: none
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
            # e2e volumes are mostly empty; let longhorn over-provision so all the
            # storage-backed modules' volumes schedule on the (thin) node disks.
            - name: defaultSettings.storageOverProvisioningPercentage
              value: "1000"
            - name: defaultSettings.storageMinimalAvailablePercentage
              value: "5"
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
DNS.1 = ingress.${module.vms.dash}-2.nip.io
DNS.2 = *.ingress.${module.vms.dash}-2.nip.io
EOF
}

# extra haproxy frontends/backends for ingress (referenced via {file://} in the
# furyctl.yaml); backends are this run's worker nodePorts on its subnet.
output "haproxy_additional" {
  value = <<EOF
frontend ingress-http
    mode tcp
    bind *:80
    default_backend ingress-http

backend ingress-http
    server worker0 ${module.vms.subnet}.9:31080 maxconn 256 check

frontend ingress-https
    mode tcp
    bind *:443
    default_backend ingress-https

backend ingress-https
    server worker0 ${module.vms.subnet}.9:31443 maxconn 256 check
EOF
}
