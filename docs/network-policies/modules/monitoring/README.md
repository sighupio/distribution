# Monitoring Module Network Policies

## Components
- Prometheus Stack
- Mimir Stack

## Namespaces
- monitoring

## Network Policies List

### Common Policies
- deny-all
- all-egress-kube-dns
- alertmanager-main
- alertmanager-ingress-nginx
- blackbox-exporter
- grafana
- grafana-egress-tempo-gateway
- grafana-ingress-nginx
- kube-state-metrics
- node-exporter
- prometheus-ingress-nginx
- prometheus-adapter
- prometheus-ingress-prometheus-adapter
- prometheus-operator
- x509-exporter-egress-kube-apiserver
- x509-exporter-ingress-prometheus-metrics
- kube-state-metrics

### MinIO
- minio-ingress-namespace
- minio-buckets-setup-egress-kube-apiserver
- minio-buckets-setup-egress-minio
- minio-ingress-prometheus-metrics
- minio-monitoring-egress-all

### Prometheus specific
- prometheus-k8s
- prometheus-egress-minio
- prometheus-egress-kube-apiserver
- prometheus-ingress-kube-apiserver (when Headlamp is enabled)

### Mimir specific
- mimir-distributed-discovery
- mimir-distributed-ingress-prometheus-metrics
- mimir-gateway-ingress-grafana
- mimir-querier-egress-https
- mimir-ingester-egress-https
- mimir-distributed-egress-minio (when using MinIO)
- mimir-distributed-egress-all (when not using MinIO)

## Configurations
- [Prometheus Stack](prometheus.md)
- [Mimir Stack](mimir.md)

