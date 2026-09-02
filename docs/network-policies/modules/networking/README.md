# Networking Module Network Policies

## Components
- Calico Whisker

## Namespaces
- `calico-system`

## Network Policies List

> The Tigera Operator ships a default-deny Ingress NetworkPolicy on the
> Whisker pod, so without an explicit allow rule the UI is unreachable
> through the ingress.

- whisker-ingress-pomerium (with SSO and `overrides.ingresses.whisker.disableAuth = false`)
- whisker-ingress-nginx (if NGINX is enabled and whisker is not behind SSO)
- whisker-ingress-haproxy (if HAProxy is enabled and whisker is not behind SSO)
- whisker-ingress-byoic (in BYOIC mode)
