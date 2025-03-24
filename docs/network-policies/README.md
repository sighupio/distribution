# Network Policies Documentation

This documentation describes all Network Policies of the SKD components for the OnPremises schema.

## Modules
- [Auth](modules/auth/README.md) - Pomerium SSO
- [Ingress](modules/ingress/README.md) - Nginx (single/dual) + Cert-manager
- [Logging](modules/logging/README.md) - OpenSearch/Loki
- [Monitoring](modules/monitoring/README.md) - Prometheus/Mimir
- [OPA](modules/opa/README.md) - Gatekeeper/Kyverno
- [Tracing](modules/tracing/README.md) - Tempo

## Common Patterns
All namespaces include:
- Default deny-all policy
- DNS access to kube-dns
- Prometheus metrics collection
- Kubernetes API server access where needed

## High Level Overview
- [Overview](overview.md)

## Instructions
Generate the new Network Policies diagrams with `make generate-np-diagrams`.