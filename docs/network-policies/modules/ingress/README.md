# Ingress Module Network Policies

## Components
- NGINX Ingress Controller (single/dual mode)
- HAProxy Ingress Controller (single/dual mode)
- Cert-manager
- External-DNS
- Forecastle

## Namespaces
- `ingress-nginx`
- `ingress-haproxy`
- `cert-manager`
- `external-dns`
- `forecastle`

## Network Policies List

### Cert-manager
- `deny-all`
- `all-egress-kube-dns`
- `cert-manager-egress-kube-apiserver`
- `cert-manager-webhook-ingress-kube-apiserver`
- `cert-manager-egress-https`
- `cert-manager-ingress-prometheus-metrics`
- `acme-http-solver-ingress-lets-encrypt` (with SSO)

### Ingress-nginx
- `deny-all`
- `all-egress-kube-dns`
- `nginx-egress-all`
- `all-ingress-nginx`
- `nginx-ingress-prometheus-metrics`

### Ingress-haproxy
- `deny-all`
- `all-egress-kube-dns`
- `all-egress-kube-apiserver`
- `haproxy-egress-all`
- `all-ingress-haproxy`
- `haproxy-ingress-prometheus-metrics`

### External-DNS
- `deny-all`
- `all-egress-kube-dns`
- `external-dns-egress-all`

### Forecastle
- `deny-all`
- `all-egress-kube-dns`
- `forecastle-ingress-nginx` (if NGINX is enabled)
- `forecastle-ingress-haproxy` (if HAProxy is enabled)
- `forecastle-ingress-pomerium` (with SSO)
- `forecastle-ingress-byoic` (in BYOIC mode)
- `forecastle-egress-kube-apiserver`

## Configurations

The diagrams below focus on the NGINX reference deployment:
- [Single Nginx](single.md)
- [Dual Nginx](dual.md)

When HAProxy is enabled, the same deny-all/DNS/Metrics patterns are applied in the `ingress-haproxy` namespace and Forecastle policies will reference HAProxy instead of NGINX.
