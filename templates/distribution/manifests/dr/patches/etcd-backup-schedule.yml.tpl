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
  schedule: "{{ .spec.distribution.modules.dr.etcdBackup.schedule }}"
{{- end }}
{{- end }}
