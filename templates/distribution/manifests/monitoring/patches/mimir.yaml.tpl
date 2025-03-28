# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

activity_tracker:
  filepath: /active-query-tracker/activity.log
alertmanager:
  data_dir: /data
  enable_api: true
  external_url: /alertmanager
  fallback_config_file: /configs/alertmanager_fallback_config.yaml
blocks_storage:
  backend: s3
  bucket_store:
    sync_dir: /data/tsdb-sync
{{- if eq .spec.distribution.modules.monitoring.mimir.backend "minio" }}
  s3:
    bucket_name: mimir
{{- end }}
{{- if eq .spec.distribution.modules.monitoring.mimir.backend "externalEndpoint" }}
  s3:
    bucket_name: {{ .spec.distribution.modules.monitoring.mimir.externalEndpoint.bucketName }}
{{- end }}
  tsdb:
    dir: /data/tsdb
    head_compaction_interval: 15m
    wal_replay_concurrency: 3
common:
  storage:
    backend: s3
{{- if eq .spec.distribution.modules.monitoring.mimir.backend "minio" }}
    s3:
      access_key_id: {{ .spec.distribution.modules.monitoring.minio.rootUser.username }}
      endpoint: minio-monitoring:9000
      insecure: true
      secret_access_key: {{ .spec.distribution.modules.monitoring.minio.rootUser.password }}
{{- end }}
{{- if eq .spec.distribution.modules.monitoring.mimir.backend "externalEndpoint" }}
    s3:
      access_key_id: {{ .spec.distribution.modules.monitoring.mimir.externalEndpoint.accessKeyId }}
      endpoint: {{ .spec.distribution.modules.monitoring.mimir.externalEndpoint.endpoint }}
      insecure: {{ .spec.distribution.modules.monitoring.mimir.externalEndpoint.insecure }}
      secret_access_key: {{ .spec.distribution.modules.monitoring.mimir.externalEndpoint.secretAccessKey }}
{{- end }}
compactor:
  compaction_interval: 30m
  data_dir: /data
  deletion_delay: 2h
  first_level_compaction_wait_period: 25m
  max_closing_blocks_concurrency: 2
  max_opening_blocks_concurrency: 4
  sharding_ring:
    wait_stability_min_duration: 1m
  symbols_flushers_concurrency: 4
frontend:
  parallelize_shardable_queries: true
  scheduler_address: mimir-distributed-query-scheduler-headless.monitoring.svc:9095
frontend_worker:
  grpc_client_config:
    max_send_msg_size: 419430400
  scheduler_address: mimir-distributed-query-scheduler-headless.monitoring.svc:9095
ingester:
  ring:
    final_sleep: 0s
    num_tokens: 512
    tokens_file_path: /data/tokens
    unregister_on_shutdown: false
ingester_client:
  grpc_client_config:
    max_recv_msg_size: 104857600
    max_send_msg_size: 104857600
limits:
  max_global_series_per_user: 0 # we disable the limit on series a user can push because we have only Prometheus pushing with the fury user.
  ingestion_burst_size: 2000000 # 10x the default
  ingestion_rate: 100000 # 10x the default
  max_cache_freshness: 10m
  max_query_parallelism: 240
  max_total_query_length: 12000h
  compactor_blocks_retention_period: {{ .spec.distribution.modules.monitoring.mimir.retentionTime }} # 30 days retention by default
memberlist:
  abort_if_cluster_join_fails: false
  compression_enabled: false
  join_members:
  - dns+mimir-distributed-gossip-ring.monitoring.svc.cluster.local:7946
querier:
  max_concurrent: 16
query_scheduler:
  max_outstanding_requests_per_tenant: 800
ruler:
  alertmanager_url: dnssrvnoa+http://_http-metrics._tcp.mimir-distributed-alertmanager-headless.monitoring.svc.cluster.local/alertmanager
  enable_api: true
  rule_path: /data
runtime_config:
  file: /var/mimir/runtime.yaml
server:
  grpc_server_max_concurrent_streams: 1000
  grpc_server_max_connection_age: 2m
  grpc_server_max_connection_age_grace: 5m
  grpc_server_max_connection_idle: 1m
store_gateway:
  sharding_ring:
    tokens_file_path: /data/tokens
    unregister_on_shutdown: false
    wait_stability_min_duration: 1m
usage_stats:
  installation_mode: helm
