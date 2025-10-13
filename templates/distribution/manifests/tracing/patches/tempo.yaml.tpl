compactor:
    compaction:
        block_retention: {{ .spec.distribution.modules.tracing.tempo.retentionTime }} # 30 days retention by default
        compacted_block_retention: 1h
        compaction_cycle: 30s
        compaction_window: 1h
        max_block_bytes: 107374182400
        max_compaction_objects: 6000000
        max_time_per_tenant: 5m
        retention_concurrency: 10
        v2_in_buffer_bytes: 5242880
        v2_out_buffer_bytes: 20971520
        v2_prefetch_traces_count: 1000
    ring:
        kvstore:
            store: memberlist
distributor:
    receivers:
        jaeger:
            protocols:
                grpc:
                    endpoint: 0.0.0.0:14250
                thrift_binary:
                    endpoint: 0.0.0.0:6832
                thrift_compact:
                    endpoint: 0.0.0.0:6831
                thrift_http:
                    endpoint: 0.0.0.0:14268
        opencensus:
            endpoint: 0.0.0.0:55678
        otlp:
            protocols:
                grpc:
                    endpoint: 0.0.0.0:4317
                http:
                    endpoint: 0.0.0.0:4318
        zipkin:
            endpoint: 0.0.0.0:9411
    ring:
        kvstore:
            store: memberlist
ingester:
    lifecycler:
        ring:
            kvstore:
                store: memberlist
            replication_factor: 3
        tokens_file_path: /var/tempo/tokens.json
memberlist:
    abort_if_cluster_join_fails: false
    bind_addr: []
    bind_port: 7946
    gossip_interval: 1s
    gossip_nodes: 2
    gossip_to_dead_nodes_time: 30s
    join_members:
    - dns+tempo-distributed-gossip-ring:7946
    leave_timeout: 5s
    left_ingesters_timeout: 5m
    max_join_backoff: 1m
    max_join_retries: 10
    min_join_backoff: 1s
    node_name: ""
    packet_dial_timeout: 5s
    packet_write_timeout: 5s
    pull_push_interval: 30s
    randomize_node_name: true
    rejoin_interval: 0s
    retransmit_factor: 2
    stream_timeout: 10s
multitenancy_enabled: false
overrides:
    metrics_generator_processors: []
    per_tenant_override_config: /runtime-config/overrides.yaml
querier:
    frontend_worker:
        frontend_address: tempo-distributed-query-frontend-discovery:9095
    max_concurrent_queries: 20
    search:
        query_timeout: 30s
    trace_by_id:
        query_timeout: 10s
query_frontend:
    max_outstanding_per_tenant: 2000
    max_retries: 2
    search:
        concurrent_jobs: 1000
        target_bytes_per_job: 104857600
    trace_by_id:
        query_shards: 50
server:
    grpc_server_max_recv_msg_size: 4194304
    grpc_server_max_send_msg_size: 4194304
    http_listen_port: 3100
    http_server_read_timeout: 30s
    http_server_write_timeout: 30s
    log_format: logfmt
    log_level: info
storage:
    trace:
        backend: s3
        blocklist_poll: 5m
        cache: memcached
        local:
            path: /var/tempo/traces
        memcached:
            consistent_hash: true
            host: tempo-distributed-memcached
            service: memcached-client
            timeout: 500ms
{{- if eq .spec.distribution.modules.tracing.tempo.backend "minio" }}
        s3:
            access_key: {{ .spec.distribution.modules.tracing.minio.rootUser.username }}
            bucket: tempo
            endpoint: minio-tracing:9000
            insecure: true
            secret_key: {{ .spec.distribution.modules.tracing.minio.rootUser.password }}
{{- end }}
{{- if eq .spec.distribution.modules.tracing.tempo.backend "externalEndpoint" }}
        s3:
            access_key: {{ .spec.distribution.modules.tracing.tempo.externalEndpoint.accessKeyId }}
            endpoint: {{ .spec.distribution.modules.tracing.tempo.externalEndpoint.endpoint }}
            insecure: {{ .spec.distribution.modules.tracing.tempo.externalEndpoint.insecure }}
            secret_key: {{ .spec.distribution.modules.tracing.tempo.externalEndpoint.secretAccessKey }}
            bucket: {{ .spec.distribution.modules.tracing.tempo.externalEndpoint.bucketName }}
{{- end }}
        wal:
            path: /var/tempo/wal
usage_report:
    reporting_enabled: true