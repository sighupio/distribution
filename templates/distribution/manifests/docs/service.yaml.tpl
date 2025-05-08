---
apiVersion: v1
kind: Service
metadata:
  name: sd-docs
  labels:
    app.kubernetes.io/name: docs
    app.kubernetes.io/version: "{{ .spec.distributionVersion }}"
    app.kubernetes.io/part-of: sighup-distribution
spec:
  selector:
    app.kubernetes.io/name: docs
    app.kubernetes.io/version: "{{ .spec.distributionVersion }}"
    app.kubernetes.io/part-of: sighup-distribution
  ports:
    - name: http
      port: 80
      targetPort: http
