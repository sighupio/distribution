# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- if eq .spec.distribution.modules.dr.etcdBackup.type "all" "pvc" }}
{{- if not (index .spec.distribution.modules.dr.etcdBackup.pvc "name") }}
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: etcd-backup-pvc-storage
spec:
{{- if .spec.distribution.modules.dr.etcdBackup.pvc.storageClass }}
  storageClassName: {{ .spec.distribution.modules.dr.etcdBackup.pvc.storageClass }}
{{- end }}
{{- if index .spec.distribution.modules.dr.etcdBackup.pvc "accessModes" }}
  accessModes:
{{ .spec.distribution.modules.dr.etcdBackup.pvc.accessModes | toYaml | indent 2 }}
{{- end }}
  resources:
    requests:
      storage: {{ .spec.distribution.modules.dr.etcdBackup.pvc.size }}
{{- end }}
{{- end }}
