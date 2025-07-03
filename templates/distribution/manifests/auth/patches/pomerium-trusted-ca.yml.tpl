# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

apiVersion: apps/v1
kind: Deployment
metadata:
  name: pomerium
  namespace: pomerium
spec:
  template:
    spec:
      containers:
      - name: pomerium
        env:
        - name: CERTIFICATE_AUTHORITY_FILE
          value: "/tls/ca.crt"
        volumeMounts:
        - name: trusted-ca-volume
          mountPath: /tls/ca.crt
          subPath: ca.crt
      volumes:
      - name: trusted-ca-volume
        secret:
          secretName: pomerium-trusted-ca
          items:
          - key: ca.crt
            path: ca.crt