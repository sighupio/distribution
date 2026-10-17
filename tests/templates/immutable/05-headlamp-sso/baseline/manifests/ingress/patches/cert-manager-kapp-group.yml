apiVersion: apps/v1
kind: Deployment
metadata:
  name: cert-manager-cainjector
  namespace: cert-manager
  annotations:
    kapp.k14s.io/change-group: "cert-manager"
---
apiVersion: v1
kind: Service
metadata:
  name: cert-manager-cainjector
  namespace: cert-manager
  annotations:
    kapp.k14s.io/change-group: "cert-manager"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cert-manager
  namespace: cert-manager
  annotations:
    kapp.k14s.io/change-group: "cert-manager"
---
apiVersion: v1
kind: Service
metadata:
  name: cert-manager
  namespace: cert-manager
  annotations:
    kapp.k14s.io/change-group: "cert-manager"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cert-manager-webhook
  namespace: cert-manager
  annotations:
    kapp.k14s.io/change-group: "cert-manager"
---
apiVersion: v1
kind: Service
metadata:
  name: cert-manager-webhook
  namespace: cert-manager
  annotations:
    kapp.k14s.io/change-group: "cert-manager"