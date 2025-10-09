# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.
      
{{- $ciliumArgs := dict "module" "networking" "package" "cilium" "spec" .spec -}}

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cilium-operator 
  namespace: kube-system
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $ciliumArgs }}
      tolerations:
        {{ template "tolerations" $ciliumArgs }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hubble-relay
  namespace: kube-system
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $ciliumArgs }}
      tolerations:
        {{ template "tolerations" $ciliumArgs }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hubble-ui
  namespace: kube-system
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $ciliumArgs }}
      tolerations:
        {{ template "tolerations" $ciliumArgs }}
