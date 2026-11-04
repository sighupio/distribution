# Utilities Module Network Policies

## Components
- Headlamp

## Namespaces
- headlamp

## Network Policies List
- deny-all
- all-egress-kube-dns
- headlamp-egress-kube-apiserver
- headlamp-ingress-pomerium (when `headlamp.type` is `sso`)
- headlamp-ingress-nginx (when `headlamp.type` is `token-auth` and nginx is enabled)
- headlamp-ingress-haproxy (when `headlamp.type` is `token-auth` and HAProxy is enabled)
- headlamp-ingress-byoic (when `headlamp.type` is `token-auth` and BYOIC is enabled)

## Cross-module paths
- Pomerium to Headlamp: the `pomerium-egress-all` policy of the [Auth](../auth/README.md) module permits it.
- Headlamp metrics: Headlamp queries Prometheus through the API server proxy. The `prometheus-ingress-kube-apiserver` policy of the [Monitoring](../monitoring/README.md) module permits it.

## Configurations
- [Headlamp](headlamp.md)
