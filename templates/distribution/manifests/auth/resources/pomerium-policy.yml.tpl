# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{ if eq .spec.distribution.modules.auth.provider.type "sso" }}
address: ":8080"
metrics_address: ":9090"

insecure_server: true
autocert: false

routes:
  {{- if ne .spec.distribution.modules.monitoring.type "none" }}
  - from: https://{{ template "prometheusUrl" .spec }}
    to: http://prometheus-k8s.monitoring.svc.cluster.local:9090
    policy:
      {{- if hasField . "spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.monitoringPrometheus" }}
      {{- .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.monitoringPrometheus | toYaml | nindent 6 }}
      {{- else }}
      - allow:
          and:
            - authenticated_user: true
      {{- end }}
  - from: https://{{ template "alertmanagerUrl" .spec }}
    to: http://alertmanager-main.monitoring.svc.cluster.local:9093
    policy:
      {{- if hasField . "spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.monitoringAlertmanager" }}
      {{- .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.monitoringAlertmanager | toYaml | nindent 6 }}
      {{- else }}
      - allow:
          and:
            - authenticated_user: true
      {{- end }}
  - from: https://{{ template "grafanaUrl" .spec }}
    to: http://grafana.monitoring.svc.cluster.local:3000
    allow_websockets: true
    host_rewrite_header: true
    preserve_host_header: true
    pass_identity_headers: true
    policy:
      {{- if hasField . "spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.monitoringGrafana" }}
      {{- .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.monitoringGrafana | toYaml | nindent 6 }}
      {{- else }}
      - allow:
          and:
            - authenticated_user: true
      {{- end }}
  {{- if and (eq .spec.distribution.modules.monitoring.type "mimir") (eq .spec.distribution.modules.monitoring.mimir.backend "minio") }}
  - from: https://{{ template "minioMonitoringUrl" .spec }}
    to: http://minio-monitoring-console.monitoring.svc.cluster.local:9001
    allow_websockets: true
    preserve_host_header: true
    policy:
      {{- if hasField . "spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.monitoringMinioConsole" }}
      {{- .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.monitoringMinioConsole | toYaml | nindent 6 }}
      {{- else }}
      - allow:
          and:
            - authenticated_user: true
      {{- end }}
  {{- end }}
  {{- end }}

  {{- if ne .spec.distribution.modules.ingress.nginx.type "none" }}
  - from: https://{{ template "forecastleUrl" .spec }}
    to: http://forecastle.ingress-nginx.svc.cluster.local
    policy:
      {{- if hasField . "spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.ingressNgnixForecastle" }}
      {{- .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.ingressNgnixForecastle | toYaml | nindent 6 }}
      {{- else }}
      - allow:
          and:
            - authenticated_user: true
      {{- end }}
  {{- end }}

  {{- if and (ne .spec.distribution.modules.logging.type "none") (.checks.storageClassAvailable) }}
  {{- if eq .spec.distribution.modules.logging.type "opensearch" }}
  - from: https://{{ template "opensearchDashboardsUrl" .spec }}
    to: http://opensearch-dashboards.logging.svc.cluster.local:5601
    policy:
      {{- if hasField . "spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.loggingOpensearchDashboards" }}
      {{- .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.loggingOpensearchDashboards | toYaml | nindent 6 }}
      {{- else }}
      - allow:
          and:
            - authenticated_user: true
      {{- end }}
  {{- end }}
  - from: https://{{ template "minioLoggingUrl" .spec }}
    to: http://minio-logging-console.logging.svc.cluster.local:9001
    allow_websockets: true
    preserve_host_header: true
    policy:
      {{- if hasField . "spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.loggingMinioConsole" }}
      {{- .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.loggingMinioConsole | toYaml | nindent 6 }}
      {{- else }}
      - allow:
          and:
            - authenticated_user: true
      {{- end }}
  {{- end }}
  {{- if and (eq .spec.distribution.modules.tracing.type "tempo") (eq .spec.distribution.modules.tracing.tempo.backend "minio") (.checks.storageClassAvailable) }}
  - from: https://{{ template "minioTracingUrl" .spec }}
    to: http://minio-tracing-console.tracing.svc.cluster.local:9001
    allow_websockets: true
    preserve_host_header: true
    policy:
      {{- if hasField . "spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.tracingMinioConsole" }}
      {{- .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.tracingMinioConsole | toYaml | nindent 6 }}
      {{- else }}
      - allow:
          and:
            - authenticated_user: true
      {{- end }}
  {{- end }}

  {{- if eq .spec.distribution.modules.policy.type "gatekeeper" }}
  - from: https://{{ template "gpmUrl" .spec }}
    to: http://gatekeeper-policy-manager.gatekeeper-system.svc.cluster.local
    policy:
      {{- if hasField . "spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.gatekeeperPolicyManager" }}
      {{- .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.gatekeeperPolicyManager | toYaml | nindent 6 }}
      {{- else }}
      - allow:
          and:
            - authenticated_user: true
      {{- end }}
  {{- end }}

  {{- if eq .spec.distribution.modules.networking.type "cilium" }}
  - from: https://{{ template "hubbleUrl" .spec }}
    to: http://hubble-ui.kube-system.svc.cluster.local
    policy:
      {{- if hasField . "spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.hubbleUi" }}
      {{- .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.hubbleUi | toYaml | nindent 6 }}
      {{- else }}
      - allow:
          and:
            - authenticated_user: true
      {{- end }}
  {{- end }}

  {{- if index .spec.distribution.modules.auth.pomerium "routes" }}
  {{- .spec.distribution.modules.auth.pomerium.routes | toYaml | nindent 2 }}
  {{- else if index .spec.distribution.modules.auth.pomerium "policy" }}
{{ .spec.distribution.modules.auth.pomerium.policy | indent 2 }}
  {{- end }}
{{ end }}
