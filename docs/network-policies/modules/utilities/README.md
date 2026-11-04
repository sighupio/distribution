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
- SD plugins: the plugins in the Headlamp image send their requests to the API server, which proxies some of them to services in other namespaces. These policies permit the proxied requests:
  - Metrics, alerts and certificates (Prometheus, 9090/TCP): `prometheus-ingress-kube-apiserver` in the [Monitoring](../monitoring/README.md) module.
  - Logs and events with Loki (Loki gateway, 8080/TCP): `loki-distributed-gateway-ingress-kube-apiserver` in the [Logging](../logging/README.md) module.
  - Logs and events with OpenSearch (9200/TCP): `opensearch-ingress-kube-apiserver` in the [Logging](../logging/README.md) module.
  - The other plugins use only Kubernetes API resources.

## Configurations
- [Headlamp](headlamp.md)
