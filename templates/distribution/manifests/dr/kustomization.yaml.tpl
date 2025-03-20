# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
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
{{- if eq .spec.distribution.modules.dr.etcdBackup.type "all" "s3" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/dr/katalog/etcd-backup-s3" }}
{{- end}}
{{- if eq .spec.distribution.modules.dr.etcdBackup.type "all" "pvc" }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/dr/katalog/etcd-backup-pvc" }}
{{- end}}
{{- end }}
{{- if .spec.distribution.modules.dr.velero.schedules.install }}
  - {{ print "../" .spec.distribution.common.relativeVendorPath "/modules/dr/katalog/velero/velero-schedules" }}
{{- end }}
{{- if eq .spec.distribution.common.provider.type "eks" }}
  - resources/eks-velero-backupstoragelocation.yml
  - resources/eks-velero-volumesnapshotlocation.yml
{{- end }}

{{- if eq .spec.distribution.common.provider.type "none" }}
{{- if ne .spec.distribution.modules.dr.etcdBackup.type "none" }}
patches:
  - path: patches/etcd-backup-schedule.yml
{{- if eq .spec.distribution.modules.dr.etcdBackup.type "all" "pvc" }}
  - patch: |-
      - op: replace
        path: /spec/jobTemplate/spec/template/spec/volumes/2/persistentVolumeClaim/claimName
        value: {{ .spec.distribution.modules.dr.etcdBackup.pvc.claimName }}
    target:
      group: batch
      version: v1
      kind: CronJob
      name: etcd-backup-pvc
{{- end }}
{{- end }}
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

{{- if eq .spec.distribution.common.provider.type "none" }}
{{- if ne .spec.distribution.modules.dr.etcdBackup.type "none" }}
configMapGenerator:
{{- if eq .spec.distribution.modules.dr.etcdBackup.type "all" "s3" }}
  - name: etcd-backup-s3-config
    behavior: replace
    literals:
      - target={{ print "s3:" .spec.distribution.modules.dr.etcdBackup.s3.bucketName }}
      - retention={{ .spec.distribution.modules.dr.etcdBackup.s3.retentionTime }}

    {{/*
      We specifically check for nil because otherwise Go's template engine considers a nil value (i.e. a non existing field) the same as the zero value (falsy-values).

      The rationale here is if backupPrefix's left unset (i.e. nil value) we apply the cluster's name, if empty we want an empty prefix (i.e. only the date + .etcdb).
    */}}
    {{- if eq (index .spec.distribution.modules.dr.etcdBackup "backupPrefix") nil }}
      - backup-prefix={{ print .metadata.name "-" }}
    {{- else}}
      - backup-prefix={{ .spec.distribution.modules.dr.etcdBackup.backupPrefix }}
    {{- end}}

{{- end }}
{{- if eq .spec.distribution.modules.dr.etcdBackup.type "all" "pvc" }}
  - name: etcd-backup-pvc-config
    behavior: replace
    literals:
      - retention={{ .spec.distribution.modules.dr.etcdBackup.pvc.retentionTime }}
    {{/* Same as above comment. */}}
    {{- if eq (index .spec.distribution.modules.dr.etcdBackup "backupPrefix") nil }}
      - backup-prefix={{ print .metadata.name "-" }}
    {{- else}}
      - backup-prefix={{ .spec.distribution.modules.dr.etcdBackup.backupPrefix }}
    {{- end}}
{{- end }}
{{- end }}
{{- end }}

{{- if eq .spec.distribution.common.provider.type "none" }}
secretGenerator:
{{- if eq .spec.distribution.modules.dr.velero.backend "externalEndpoint" }}
- name: cloud-credentials
  namespace: kube-system
  files:
    - cloud=secrets/cloud-credentials.config
{{- end }}
{{- if eq .spec.distribution.modules.dr.etcdBackup.type "all" "s3" }}
  - name: etcd-backup-s3-rclone-conf
    behavior: replace
    files:
      - secrets/rclone.conf
{{- end }}
{{- end }}
