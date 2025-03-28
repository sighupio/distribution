# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# THIS FILE HAS BEEN PATCHED BY FURYCTL TO ENSURE BACKWARDS COMPATIBILITY.
# IT IS NOT THE ORIGINAL FILE FOUND IN THE DISTRIBUTION REPOSITORY.

{{- if eq .spec.distribution.common.provider.type "eks" }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: {{ .spec.distribution.modules.dr.velero.eks.iamRoleArn }}
  name: velero
  namespace: kube-system
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: velero
  namespace: kube-system
spec:
  template:
    spec:
      containers:
      - name: velero
        volumeMounts:
        - name: cloud-credentials
          mountPath: /credentials
          $patch: delete
        env: 
        - name: GOOGLE_APPLICATION_CREDENTIALS
          value: /credentials/cloud
          $patch: delete
        - name: AWS_SHARED_CREDENTIALS_FILE
          value: /credentials/cloud
          $patch: delete
        - name: AZURE_CREDENTIALS_FILE
          value: /credentials/cloud
          $patch: delete
      volumes:
      - name: cloud-credentials
        $patch: delete
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: node-agent
  labels:
    k8s-app: velero-node-agent
  namespace: kube-system
spec:
  template:
    spec:
      containers:
      - name: node-agent
        volumeMounts:
        - name: cloud-credentials
          mountPath: /credentials
          $patch: delete
        env: 
        - name: GOOGLE_APPLICATION_CREDENTIALS
          value: /credentials/cloud
          $patch: delete
        - name: AWS_SHARED_CREDENTIALS_FILE
          value: /credentials/cloud
          $patch: delete
        - name: AZURE_CREDENTIALS_FILE
          value: /credentials/cloud
          $patch: delete
      volumes:
      - name: cloud-credentials
        $patch: delete
{{- end }}
