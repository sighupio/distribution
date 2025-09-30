# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

apiVersion: apps/v1
kind: Deployment
metadata:
  name: kyverno-admission-controller
  namespace: kyverno
  annotations:
    kapp.k14s.io/change-group: "kyverno-core"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kyverno-background-controller
  namespace: kyverno
  annotations:
    kapp.k14s.io/change-group: "kyverno-core"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kyverno-cleanup-controller
  namespace: kyverno
  annotations:
    kapp.k14s.io/change-group: "kyverno-core"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kyverno-reports-controller
  namespace: kyverno
  annotations:
    kapp.k14s.io/change-group: "kyverno-core"
---
apiVersion: v1
kind: Service
metadata:
  name: kyverno-svc
  namespace: kyverno
  annotations:
    kapp.k14s.io/change-group: "kyverno-core"
---
apiVersion: v1
kind: Service
metadata:
  name: kyverno-svc-metrics
  namespace: kyverno
  annotations:
    kapp.k14s.io/change-group: "kyverno-core"
---
apiVersion: v1
kind: Service
metadata:
  name: kyverno-background-controller-metrics
  namespace: kyverno
  annotations:
    kapp.k14s.io/change-group: "kyverno-core"
---
apiVersion: v1
kind: Service
metadata:
  name: kyverno-cleanup-controller
  namespace: kyverno
  annotations:
    kapp.k14s.io/change-group: "kyverno-core"
---
apiVersion: v1
kind: Service
metadata:
  name: kyverno-cleanup-controller-metrics
  namespace: kyverno
  annotations:
    kapp.k14s.io/change-group: "kyverno-core"
---
apiVersion: v1
kind: Service
metadata:
  name: kyverno-reports-controller-metrics
  namespace: kyverno
  annotations:
    kapp.k14s.io/change-group: "kyverno-core"
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-capabilities
  annotations:
    kapp.k14s.io/change-rule: "upsert after upserting customresourcedefinition/clusterpolicies.kyverno.io"
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-capabilities-strict
  annotations:
    kapp.k14s.io/change-rule: "upsert after upserting customresourcedefinition/clusterpolicies.kyverno.io"
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-host-namespaces
  annotations:
    kapp.k14s.io/change-rule: "upsert after upserting customresourcedefinition/clusterpolicies.kyverno.io"
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-host-path
  annotations:
    kapp.k14s.io/change-rule: "upsert after upserting customresourcedefinition/clusterpolicies.kyverno.io"
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-host-ports
  annotations:
    kapp.k14s.io/change-rule: "upsert after upserting customresourcedefinition/clusterpolicies.kyverno.io"
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-latest-tag
  annotations:
    kapp.k14s.io/change-rule: "upsert after upserting customresourcedefinition/clusterpolicies.kyverno.io"
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-privilege-escalation
  annotations:
    kapp.k14s.io/change-rule: "upsert after upserting customresourcedefinition/clusterpolicies.kyverno.io"
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-privileged-containers
  annotations:
    kapp.k14s.io/change-rule: "upsert after upserting customresourcedefinition/clusterpolicies.kyverno.io"
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: disallow-proc-mount
  annotations:
    kapp.k14s.io/change-rule: "upsert after upserting customresourcedefinition/clusterpolicies.kyverno.io"
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-pod-probes
  annotations:
    kapp.k14s.io/change-rule: "upsert after upserting customresourcedefinition/clusterpolicies.kyverno.io"
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-run-as-nonroot
  annotations:
    kapp.k14s.io/change-rule: "upsert after upserting customresourcedefinition/clusterpolicies.kyverno.io"
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: restrict-sysctls
  annotations:
    kapp.k14s.io/change-rule: "upsert after upserting customresourcedefinition/clusterpolicies.kyverno.io"
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: unique-ingress-host-and-path
  annotations:
    kapp.k14s.io/change-rule: "upsert after upserting customresourcedefinition/clusterpolicies.kyverno.io"