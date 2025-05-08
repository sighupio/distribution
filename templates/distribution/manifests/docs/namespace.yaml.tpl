apiVersion: v1
kind: Namespace
metadata:
  name: sd-docs
  labels:
    app.kubernetes.io/name: docs
    app.kubernetes.io/version: "{{ .spec.distributionVersion }}"
    app.kubernetes.io/part-of: sighup-distribution
