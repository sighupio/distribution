# Networking Module Network Policies

## Components
- Calico Whisker

## Namespaces
- `calico-system`

## Network Policies List

> The Tigera Operator ships the `calico-system.whisker` policy in the
> `calico-system` Calico tier, with no ingress rules: the tier is evaluated
> before Kubernetes NetworkPolicies and denies by default. The allow rules
> below are therefore Calico `NetworkPolicy` resources
> (`crd.projectcalico.org/v1`) in the same tier, prefixed with
> `calico-system.`. Without them the UI is unreachable through the ingress.

- calico-system.whisker-ingress-pomerium (with SSO and `overrides.ingresses.whisker.disableAuth = false`)
- calico-system.whisker-ingress-nginx (if NGINX is enabled and whisker is not behind SSO)
- calico-system.whisker-ingress-haproxy (if HAProxy is enabled and whisker is not behind SSO)
- calico-system.whisker-ingress-byoic (in BYOIC mode)
