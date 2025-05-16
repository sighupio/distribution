# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

resourceRules:
  cpu:
    containerLabel: container
    containerQuery: |
      sum by (<<.GroupBy>>) (
        irate (
            container_cpu_usage_seconds_total{<<.LabelMatchers>>,container!="",pod!=""}[120s]
        )
      )
    nodeQuery: |
      sum by (<<.GroupBy>>) (
        1 - irate(
          node_cpu_seconds_total{mode="idle"}[60s]
        )
        * on(namespace, pod) group_left(node) (
          node_namespace_pod:kube_pod_info:{<<.LabelMatchers>>}
        )
      )
      or sum by (<<.GroupBy>>) (
        1 - irate(
          windows_cpu_time_total{mode="idle", job="windows-exporter",<<.LabelMatchers>>}[4m]
        )
      )
    resources:
      overrides:
        namespace:
          resource: namespace
        node:
          resource: node
        pod:
          resource: pod
  memory:
    containerLabel: container
    containerQuery: |
      sum by (<<.GroupBy>>) (
        container_memory_working_set_bytes{<<.LabelMatchers>>,container!="",pod!=""}
      )
    nodeQuery: |
      sum by (<<.GroupBy>>) (
        node_memory_MemTotal_bytes{job="node-exporter",<<.LabelMatchers>>}
        -
        node_memory_MemAvailable_bytes{job="node-exporter",<<.LabelMatchers>>}
      )
      or sum by (<<.GroupBy>>) (
        windows_cs_physical_memory_bytes{job="windows-exporter",<<.LabelMatchers>>}
        -
        windows_memory_available_bytes{job="windows-exporter",<<.LabelMatchers>>}
      )
    resources:
      overrides:
        instance:
          resource: node
        namespace:
          resource: namespace
        pod:
          resource: pod
  window: 5m
