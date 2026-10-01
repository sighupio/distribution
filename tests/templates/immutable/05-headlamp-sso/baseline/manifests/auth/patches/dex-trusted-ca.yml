# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

apiVersion: apps/v1
kind: Deployment
metadata:
  name: dex
  namespace: kube-system
spec:
  template:
    spec:
      containers:
      - name: dex
        volumeMounts:
        - name: trusted-ca
          mountPath: /etc/dex/tls/ca.crt
          subPath: ca.crt
      volumes:
      - name: trusted-ca
        secret:
          secretName: oidc-trusted-ca
          items:
          - key: ca.crt
            path: ca.crt
