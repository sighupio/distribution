# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

locals {
  vip_fqdn  = "10-10-${local.octet}-20.nip.io"
  ingress   = "ingress.${local.vip_fqdn}"
  lbs       = [for k in ["lb-0", "lb-1"] : local.nodes[k]]
  cps       = [for k in ["controlplane-0", "controlplane-1", "controlplane-2"] : local.nodes[k]]
  infras    = [for k in ["infra-0", "infra-1", "infra-2"] : local.nodes[k]]
  worker    = local.nodes["worker-0"]
  k8s_nodes = concat(local.cps, local.infras, [local.worker])
}

output "vms" {
  value = [for k, _ in local.nodes : libvirt_domain.vm[k].name]
}

output "ipxe_url" {
  value = local.ipxe
}

# kube-bench runs on one node per role, as in the on-premises pipeline.
output "controlplane_0" {
  value = local.nodes["controlplane-0"].fqdn
}

output "worker_0" {
  value = local.worker.fqdn
}

# worker-0 uses DHCP after install and every other node a static address, so both
# network configurations are covered. The Kubernetes nodes enable iscsid, which
# longhorn needs to attach volumes (Flatcar ships it disabled).
output "furyctl_yaml" {
  value = <<EOT
---
apiVersion: kfd.sighup.io/v1alpha2
kind: Immutable
metadata:
  # fixed, so the furyctl assets dir has a stable path for the pipeline cache
  name: e2e-immutable
spec:
  distributionVersion: v1.36.0
  infrastructure:
    ssh:
      username: core
      privateKeyPath: ${var.private_key_path}
    ipxeServer:
      url: ${local.ipxe}
    nodes:
%{~for n in local.lbs}
      - hostname: ${n.fqdn}
        macAddress: "${n.mac}"
        arch: x86-64
        storage:
          installDisk: /dev/vda
        network:
          ethernets:
            eth0:
              addresses: ["${n.ip}/24"]
              gateway: ${local.gateway}
              nameservers:
                addresses: [8.8.8.8, 1.1.1.1]
%{~endfor}
%{~for n in local.k8s_nodes}
      - hostname: ${n.fqdn}
        macAddress: "${n.mac}"
        arch: x86-64
        storage:
          installDisk: /dev/vda
          files:
            - path: /etc/modules-load.d/iscsi_tcp.conf
              contents:
                inline: iscsi_tcp
        systemd:
          units:
            - name: iscsid.service
              enabled: true
        network:
          ethernets:
            eth0:
%{~if n.fqdn == local.worker.fqdn}
              dhcp4: true
%{~else}
              addresses: ["${n.ip}/24"]
              gateway: ${local.gateway}
              nameservers:
                addresses: [8.8.8.8, 1.1.1.1]
%{~endif}
%{~endfor}
    loadBalancers:
      members:
%{~for n in local.lbs}
        - hostname: ${n.fqdn}
%{~endfor}
      keepalived:
        enabled: true
        interface: eth0
        ip: ${local.vip}
        virtualRouterId: "201"
        passphrase: "b16cf069"
      # Replaces the default configuration, so it repeats the API frontend and
      # adds the ingress frontends (worker-0 nodePorts).
      haproxy:
        configuration: |
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
%{~for n in local.cps}
              server ${n.fqdn} ${n.fqdn}:6443 check check-ssl ca-file /usr/local/etc/haproxy/kubernetes.crt
%{~endfor}

          frontend ingress-http
              mode tcp
              bind *:80
              default_backend ingress-http

          backend ingress-http
              server worker0 ${local.worker.ip}:31080 maxconn 256 check

          frontend ingress-https
              mode tcp
              bind *:443
              default_backend ingress-https

          backend ingress-https
              server worker0 ${local.worker.ip}:31443 maxconn 256 check
  kubernetes:
    pkiPath: ./pki
    networking:
      podCIDR: 10.128.0.0/14
      serviceCIDR: 172.30.0.0/16
    controlPlane:
      address: api.${local.vip_fqdn}:6443
      members:
%{~for n in local.cps}
        - hostname: ${n.fqdn}
%{~endfor}
    nodeGroups:
      - name: infra
        taints: []
        nodes:
%{~for n in local.infras}
          - hostname: ${n.fqdn}
%{~endfor}
      - name: worker
        taints: []
        nodes:
          - hostname: ${local.worker.fqdn}
    advanced:
      encryption:
        configuration: "{file://../../onpremises/config/encrypted-secret-config.yaml}"
  distribution:
    # longhorn in the distribution phase: the StorageClass exists before the
    # plugins phase, but furyctl skips the storage-backed modules until a re-apply.
    customResources:
      - ${abspath("${path.module}/../longhorn")}
    common:
      nodeSelector:
        node-role.kubernetes.io/infra: ""
      networkPoliciesEnabled: true
    modules:
      networking:
        type: cilium
      ingress:
        baseDomain: ${local.ingress}
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
        loki:
          backend: minio
          tsdbStartDate: "2024-11-18"
      # prometheus and no tracing: mimir and tempo (distributed + minio) are too
      # heavy for a single-worker e2e, as in the on-premises pipeline.
      monitoring:
        type: prometheus
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
        type: none
      auth:
        provider:
          type: none
EOT
}

output "req_dns" {
  value = <<EOT
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = ${local.ingress}
DNS.2 = *.${local.ingress}
EOT
}
