# OPA Module Network Policies

## Components
- Gatekeeper + Gatekeeper Policy Manager
- Kyverno

## Namespaces
- gatekeeper-system (when using Gatekeeper)
- kyverno (when using Kyverno)

## Network Policies List

### Gatekeeper
- deny-all
- all-egress-dns
- audit-controller-egress-kube-apiserver
- controller-manager-egress-kube-apiserver
- controller-manager-ingress-kube-apiserver
- gpm-egress-kube-apiserver
- gpm-ingress-pomerium (with SSO)
- gpm-ingress-haproxy (if HAProxy is enabled, with basicAuth)
- gpm-ingress-nginx (if NGINX is enabled, with basicAuth)
- gatekeeper-ingress-prometheus-metrics

### Kyverno
- deny-all
- all-egress-dns
- kyverno-admission-egress-kube-apiserver
- kyverno-admission-ingress-nodes
- kyverno-background-egress-kube-apiserver
- kyverno-reports-egress-kube-apiserver
- kyverno-cleanup-egress-kube-apiserver
- kyverno-cleanup-reports-egress-kube-apiserver

## Configurations
- [Gatekeeper](gatekeeper.md)
- [Kyverno](kyverno.md)

