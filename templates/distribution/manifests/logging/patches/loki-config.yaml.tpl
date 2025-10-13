# Copyright (c) 2025-present SIGHUP s.r.l. All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.
#

analytics:
  reporting_enabled: false
auth_enabled: false
bloom_build:
  builder:
    planner_address: loki-distributed-bloom-planner-headless.logging.svc.cluster.local:9095
  enabled: false
distributor:
  ring:
    kvstore:
      store: memberlist
bloom_gateway:
  client:
    addresses: dnssrvnoa+_grpc._tcp.loki-distributed-bloom-gateway-headless.logging.svc.cluster.local
  enabled: false
common:
  compactor_address: 'http://loki-distributed-compactor:3100'
  path_prefix: /var/loki
  replication_factor: 1
  storage:
    s3:
{{- if eq .spec.distribution.modules.logging.loki.backend "minio" }}
      bucketnames: loki
      endpoint: http://minio-logging.logging.svc.cluster.local:9000
      insecure: true
      access_key_id: ${MINIO_ACCESS_KEY}
      secret_access_key: ${MINIO_SECRET_KEY}
      s3forcepathstyle: true
{{- end }}
{{- if eq .spec.distribution.modules.logging.loki.backend "externalEndpoint" }}
      bucketnames: {{ .spec.distribution.modules.logging.loki.externalEndpoint.bucketName }}
      endpoint: {{ ternary "http" "https" .spec.distribution.modules.logging.loki.externalEndpoint.insecure }}://{{ .spec.distribution.modules.logging.loki.externalEndpoint.endpoint }}
      insecure: {{ ternary "true" "false" .spec.distribution.modules.logging.loki.externalEndpoint.insecure }}
      access_key_id: ${MINIO_ACCESS_KEY}
      secret_access_key: ${MINIO_SECRET_KEY}
      s3forcepathstyle: true
{{- end }}
frontend:
  compress_responses: true
  log_queries_longer_than: 5s 
  scheduler_address: loki-distributed-query-scheduler.logging.svc.cluster.local:9095
  tail_proxy_url: http://loki-distributed-querier.logging.svc.cluster.local:3100
frontend_worker:
  scheduler_address: loki-distributed-query-scheduler.logging.svc.cluster.local:9095
index_gateway:
  mode: simple
ingester:
  chunk_block_size: 262144
  chunk_idle_period: 30m
  chunk_retain_period: 1m
  chunk_encoding: snappy
  lifecycler:
    ring:
      kvstore:
        store: memberlist
      replication_factor: 1
  wal:
    dir: /var/loki/wal
    flush_on_shutdown: true
limits_config:
  allow_structured_metadata: true
  max_cache_freshness_per_query: 10m
  query_timeout: 300s
  reject_old_samples: true
  reject_old_samples_max_age: 168h
  split_queries_by_interval: 15m
  volume_enabled: true
  max_label_names_per_series: 30
  retention_period: {{ .spec.distribution.modules.logging.loki.retentionTime }}
memberlist:
  join_members:
  - loki-distributed-memberlist
pattern_ingester:
  enabled: true
querier:
  max_concurrent: 4
query_range:
  align_queries_with_step: true
  cache_results: true
  results_cache:
    cache:
      embedded_cache:
        enabled: true
        ttl: 24h
runtime_config:
  file: /etc/loki/runtime-config/runtime-config.yaml
schema_config:
  configs:
  - from: "2020-10-24"
    index:
      period: 24h
      prefix: index_
    object_store: s3
    schema: v11
    store: boltdb-shipper
{{- if and (index .spec.distribution.modules.logging "loki") (index .spec.distribution.modules.logging.loki "tsdbStartDate") }}
  - from: "{{ .spec.distribution.modules.logging.loki.tsdbStartDate }}" 
    index:
      period: 24h
      prefix: index_
    object_store: s3
    schema: v13
    store: tsdb
{{- end }}
server:
  grpc_listen_port: 9095
  http_listen_port: 3100
  http_server_read_timeout: 600s
  http_server_write_timeout: 600s
storage_config:
  bloom_shipper:
    working_directory: /var/loki/data/bloomshipper
  boltdb_shipper:
    active_index_directory: /var/loki/index
    cache_location: /var/loki/cache
    cache_ttl: 24h
    resync_interval: 5s
    index_gateway_client:
      server_address: dns+loki-distributed-index-gateway-headless.logging.svc.cluster.local:9095
  hedging:
    at: 250ms
    max_per_second: 20
    up_to: 3
  tsdb_shipper:
    active_index_directory: /var/loki/index
    cache_location: /var/loki/cache
    cache_ttl: 24h
    resync_interval: 5s
    index_gateway_client:
      server_address: dns+loki-distributed-index-gateway-headless.logging.svc.cluster.local:9095
compactor:
  working_directory: /var/loki/compactor
  retention_enabled: {{ ne .spec.distribution.modules.logging.loki.retentionTime "0s" }}
  retention_delete_delay: 2h
  retention_delete_worker_count: 150
  delete_request_store: s3
tracing:
  enabled: false
