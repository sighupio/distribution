apiVersion: apps/v1
kind: Deployment
metadata:
  name: gatekeeper-audit
  namespace: gatekeeper-system
  annotations:
    kapp.k14s.io/change-group: "gatekeeper-core"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gatekeeper-controller-manager
  namespace: gatekeeper-system
  annotations:
    kapp.k14s.io/change-group: "gatekeeper-core"
---
apiVersion: v1
kind: Service
metadata:
  name: gatekeeper-audit-service
  namespace: gatekeeper-system
  annotations:
    kapp.k14s.io/change-group: "gatekeeper-core"
---
apiVersion: v1
kind: Service
metadata:
  name: gatekeeper-webhook-service
  namespace: gatekeeper-system
  annotations:
    kapp.k14s.io/change-group: "gatekeeper-core"
---
apiVersion: admissionregistration.k8s.io/v1
kind: MutatingWebhookConfiguration
metadata:
  annotations:
    kapp.k14s.io/change-group: "gatekeeper-webhooks"
    kapp.k14s.io/change-rule: "upsert after upserting gatekeeper-core"
  name: gatekeeper-mutating-webhook-configuration
---
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  annotations:
    kapp.k14s.io/change-group: "gatekeeper-webhooks"
    kapp.k14s.io/change-rule: "upsert after upserting gatekeeper-core"
  name: gatekeeper-validating-webhook-configuration