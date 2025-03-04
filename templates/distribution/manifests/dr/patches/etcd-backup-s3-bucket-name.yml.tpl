# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- if eq .spec.distribution.common.provider.type "none" }}
{{- if index .spec.distribution.modules.dr "etcdBackup" }}
apiVersion: batch/v1
kind: CronJob
metadata:
  name: etcd-backup
  namespace: kube-system
spec:
  jobTemplate:
    spec:
      template:
        spec:
          volumes:
          - name: rclone-conf
            secret:
              secretName: rclone-etcdbackup-conf
          - name: etcd-certs
            hostPath:
              path: /etc/etcd/pki/etcd
          - name: persistence
            emptyDir: {}
          containers:
          - name: rclone
            image: registry.sighup.io/fury/etcd-backup/rclone:v1.69-stable
            args: ["copy", "/etcd-backup", "minio:{{ .spec.distribution.modules.dr.etcdBackup.s3.bucketName }}"]
            volumeMounts:
            - mountPath: /config/rclone
              name: rclone-conf
              readOnly: true
            - mountPath: /etcd-backup
              name: persistence
          - name: rclone-deleter
            image: registry.sighup.io/fury/etcd-backup/rclone:v1.69-stable
            args:
            - "delete"
            - "minio:{{ .spec.distribution.modules.dr.etcdBackup.s3.bucketName }}"
            - "--min-age={{ .spec.distribution.modules.dr.etcdBackup.s3.retentionTime }}"
            - "--include=fury-etcd-snapshot*.etcdb"
            volumeMounts:
            - mountPath: /config/rclone
              name: rclone-conf
              readOnly: true
{{- end }}
{{- end }}
