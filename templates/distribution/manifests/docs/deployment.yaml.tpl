---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sd-docs
  labels:
    app.kubernetes.io/name: docs
    app.kubernetes.io/version: "{{ .spec.distributionVersion }}"
    app.kubernetes.io/part-of: sighup-distribution
spec:
  replicas: 2
  selector:
    matchLabels:
      app.kubernetes.io/name: docs
      app.kubernetes.io/version: "{{ .spec.distributionVersion }}"
      app.kubernetes.io/part-of: sighup-distribution
  strategy: {}
  template:
    metadata:
      labels:
        app.kubernetes.io/name: docs
        app.kubernetes.io/version: "{{ .spec.distributionVersion }}"
        app.kubernetes.io/part-of: sighup-distribution
    spec:
      tolerations:
        {{ template "tolerations" dict "module" "docs" "package" "docs" "spec" .spec }}
      nodeSelector:
        {{ template "nodeSelector" dict "module" "docs" "package" "docs" "spec" .spec }}
      containers:
        - name: docs
          image: registry.sighup.io/fury/docs:{{ .spec.distributionVersion | trimPrefix "v" }}-single
          ports:
            - name: http
              containerPort: 8080
          securityContext:
            privileged: false
            runAsNonRoot: true
            runAsUser: 101
            runAsGroup: 101
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            seccompProfile:
              type: RuntimeDefault
            capabilities:
              drop:
                - ALL
          volumeMounts:
            - name: tmp
              mountPath: /tmp
      volumes:
        - name: tmp
          emptyDir: {}
