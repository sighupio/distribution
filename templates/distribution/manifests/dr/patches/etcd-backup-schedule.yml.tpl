# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- if eq .spec.distribution.common.provider.type "none" }}
{{- if eq .spec.distribution.modules.dr.etcdBackup.type "all" "s3" }}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: etcd-backup-s3
  namespace: kube-system
spec:
  schedule: "{{ .spec.distribution.modules.dr.etcdBackup.s3.schedule }}"
{{- end }}

{{- if eq .spec.distribution.modules.dr.etcdBackup.type "all" "pvc" }}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: etcd-backup-pvc
  namespace: kube-system
spec:
  schedule: "{{ .spec.distribution.modules.dr.etcdBackup.pvc.schedule }}"
{{- end }}
{{- end }}
