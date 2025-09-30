# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

apiVersion: apps/v1
kind: Deployment
metadata:
  name: tigera-operator
  namespace: tigera-operator
  annotations:
    kapp.k14s.io/change-group: "tigera-core"
---
apiVersion: v1
kind: Service
metadata:
  name: tigera-operator
  namespace: tigera-operator
  annotations:
    kapp.k14s.io/change-group: "tigera-core"
---
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
  annotations:
    kapp.k14s.io/change-group: "tigera-installation"
    kapp.k14s.io/change-rule: "upsert after upserting tigera-core"