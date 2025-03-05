# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
{{- if index .spec.distribution.modules.dr "etcdBackup" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/dr/katalog/etcd-backup/etcd-backup-s3" }}
{{- end}}

{{- if eq .spec.distribution.common.provider.type "eks" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/dr/katalog/velero/velero-aws" }}
{{- else if eq .spec.distribution.common.provider.type "none" }}

{{- if eq .spec.distribution.modules.dr.velero.backend "minio" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/dr/katalog/velero/velero-on-prem" }}
{{- else }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/dr/katalog/velero/velero-aws" }}
  - resources/storageLocation.yaml
  - resources/volumeSnapshotLocation.yaml
{{- end }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/dr/katalog/velero/velero-node-agent" }}
{{- if .spec.distribution.modules.dr.velero.snapshotController.install }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/dr/katalog/velero/snapshot-controller" }}
{{- end }}

{{- end }}
{{- if .spec.distribution.modules.dr.velero.schedules.install }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/dr/katalog/velero/velero-schedules" }}
{{- end }}
{{- if eq .spec.distribution.common.provider.type "eks" }}
  - resources/eks-velero-backupstoragelocation.yml
  - resources/eks-velero-volumesnapshotlocation.yml
{{- end }}

patchesStrategicMerge:
  - patches/infra-nodes.yml
{{- if eq .spec.distribution.common.provider.type "eks" }}
  - patches/eks-velero.yml
{{- end }}
{{- if .spec.distribution.modules.dr.velero.schedules.install }}
  - patches/velero-schedule-manifests.yml
  - patches/velero-schedule-full.yml
{{- end }}
{{- if and (index .spec.distribution.modules.dr "etcdBackup") (.spec.distribution.modules.dr.etcdBackup.s3.enabled) }}
  - patches/etcd-backup-schedule.yml
{{- end }}

{{- if eq .spec.distribution.common.provider.type "none" }}
{{- if and (index .spec.distribution.modules.dr "etcdBackup") (.spec.distribution.modules.dr.etcdBackup.s3.enabled) }}
configMapGenerator:
  - name: etcd-backup-config
    behavior: replace
    literals:
      - target={{ print "minio:" .spec.distribution.modules.dr.etcdBackup.s3.bucketName }}
      - retention={{ .spec.distribution.modules.dr.etcdBackup.s3.retentionTime }}
{{- end }}
{{- end }}

secretGenerator:
{{- if eq .spec.distribution.common.provider.type "none" }}
{{- if eq .spec.distribution.modules.dr.velero.backend "externalEndpoint" }}
- name: cloud-credentials
  namespace: kube-system
  files:
    - cloud=secrets/cloud-credentials.config
{{- end }}
{{- if and (index .spec.distribution.modules.dr "etcdBackup") (.spec.distribution.modules.dr.etcdBackup.s3.enabled) }}
  - name: etcd-backup-s3-rclone-conf
    behavior: replace
    files:
      - secrets/rclone.conf
{{- end }}
{{- end }}
