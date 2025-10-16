# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- if eq .spec.distribution.common.provider.type "eks" }}
---
apiVersion: velero.io/v1
kind: BackupStorageLocation
metadata:
  name: default
  namespace: kube-system
spec:
  provider: velero.io/aws
  default: true
  objectStorage:
    bucket: {{ .spec.distribution.modules.dr.velero.eks.bucketName }}
    prefix: {{ .spec.distribution.modules.dr.velero.eks.prefixName }}
  accessMode: {{ .spec.distribution.modules.dr.velero.eks.accessMode }}
  config:
    region: {{ .spec.distribution.modules.dr.velero.eks.region }}
{{- end }}
