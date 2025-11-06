{{- if and (eq .spec.distribution.modules.logging.type "loki") (hasField . "spec.distribution.modules.logging.loki.resources") }}
{{- $resources := .spec.distribution.modules.logging.loki.resources }}
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: loki-distributed-ingester
  namespace: logging
spec:
  template:
    spec:
      containers:
      - name: ingester
        resources:
          {{ $resources | toYaml | indent 10 | trim }}
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: loki-distributed-compactor
  namespace: logging
spec:
  template:
    spec:
      containers:
      - name: compactor
        resources:
          {{ $resources | toYaml | indent 10 | trim }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: loki-distributed-distributor
  namespace: logging
spec:
  template:
    spec:
      containers:
      - name: distributor
        resources:
          {{ $resources | toYaml | indent 10 | trim }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: loki-distributed-gateway
  namespace: logging
spec:
  template:
    spec:
      containers:
      - name: nginx
        resources:
          {{ $resources | toYaml | indent 10 | trim }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: loki-distributed-query-frontend
  namespace: logging
spec:
  template:
    spec:
      containers:
      - name: query-frontend
        resources:
          {{ $resources | toYaml | indent 10 | trim }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: loki-distributed-querier
  namespace: logging
spec:
  template:
    spec:
      containers:
      - name: querier
        resources:
          {{ $resources | toYaml | indent 10 | trim }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: loki-distributed-query-scheduler
  namespace: logging
spec:
  template:
    spec:
      containers:
      - name: query-scheduler
        resources:
          {{ $resources | toYaml | indent 10 | trim }}
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: loki-distributed-index-gateway
  namespace: logging
spec:
  template:
    spec:
      containers:
      - name: index-gateway
        resources:
          {{ $resources | toYaml | indent 10 | trim }}
{{- end }}
