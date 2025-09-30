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
  name: kyverno-cleanup-controller
  namespace: kyverno
  annotations:
    kapp.k14s.io/change-group: "kyverno-core"
---
apiVersion: admissionregistration.k8s.io/v1
kind: MutatingWebhookConfiguration
metadata:
  name: kyverno-mutating-webhook-configuration
  annotations:
    kapp.k14s.io/change-group: "kyverno-webhooks"
    kapp.k14s.io/change-rule: "upsert after upserting kyverno-core"
---
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: kyverno-validating-webhook-configuration
  annotations:
    kapp.k14s.io/change-group: "kyverno-webhooks"
    kapp.k14s.io/change-rule: "upsert after upserting kyverno-core"
---
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  annotations:
    kapp.k14s.io/change-group: "kyverno-policies"
    kapp.k14s.io/change-rule: "upsert after upserting kyverno-webhooks"