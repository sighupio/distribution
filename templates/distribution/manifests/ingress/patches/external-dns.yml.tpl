# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- if eq .spec.distribution.common.provider.type "eks" }}
{{- if eq .spec.distribution.modules.ingress.nginx.type "dual" }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: {{ .spec.distribution.modules.ingress.externalDns.publicIamRoleArn }}
  name: external-dns-public
  namespace: external-dns
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: external-dns-public
  namespace: external-dns
spec:
  template:
    spec:
      containers:
      - name: external-dns
        env:
        - name: PROVIDER
          value: aws
        args:
          - --source=service
          - --source=ingress
          - --provider=$(PROVIDER)
          - --aws-zone-type=public
          - --txt-owner-id={{ .metadata.name}}-public
          - --exclude-domains={{ .spec.distribution.modules.ingress.baseDomain }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: {{ .spec.distribution.modules.ingress.externalDns.privateIamRoleArn }}
  name: external-dns-private
  namespace: external-dns
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: external-dns-private
  namespace: external-dns
spec:
  template:
    spec:
      containers:
      - name: external-dns
        env:
        - name: PROVIDER
          value: aws
        args:
          - --source=service
          - --source=ingress
          - --provider=$(PROVIDER)
          - --aws-zone-type=private
          - --txt-owner-id={{ .metadata.name}}-private

{{- end }}
{{- if eq .spec.distribution.modules.ingress.nginx.type "single" }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: {{ .spec.distribution.modules.ingress.externalDns.publicIamRoleArn }}
  name: external-dns-public
  namespace: external-dns
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: external-dns-public
  namespace: external-dns
spec:
  template:
    spec:
      containers:
      - name: external-dns
        env:
        - name: PROVIDER
          value: aws
        args:
          - --source=service
          - --source=ingress
          - --provider=$(PROVIDER)
          - --aws-zone-type=public
          - --txt-owner-id={{ .metadata.name}}-public
{{- end }}
{{- end }}
