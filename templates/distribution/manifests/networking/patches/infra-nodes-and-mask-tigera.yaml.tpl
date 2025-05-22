# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $tigeraOperatorArgs := dict "module" "networking" "package" "tigeraOperator" "spec" .spec -}}

---
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  controlPlaneNodeSelector:
    {{ template "nodeSelector" ( merge (dict "indent" 4) $tigeraOperatorArgs ) }}
  controlPlaneTolerations:
    {{ template "tolerations" ( merge (dict "indent" 4) $tigeraOperatorArgs ) }}
  typhaDeployment:
    spec:
      template:
        spec:
          nodeSelector:
            {{ template "nodeSelector" ( merge (dict "indent" 12) $tigeraOperatorArgs ) }}
          tolerations:
            {{ template "tolerations" ( merge (dict "indent" 12) $tigeraOperatorArgs ) }}
  calicoNetwork:
    ipPools:
    - blockSize: {{ .spec.distribution.modules.networking.tigeraOperator.blockSize }}
      {{- if index .spec.distribution.modules.networking.tigeraOperator "podCidr" }}
      cidr: {{ .spec.distribution.modules.networking.tigeraOperator.podCidr }}
      {{- else }}
      cidr: {{ .spec.kubernetes.podCidr }}
      {{- end }}
      name: default-ipv4-ippool
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tigera-operator
  namespace: tigera-operator
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $tigeraOperatorArgs }}
      tolerations:
        {{ template "tolerations" $tigeraOperatorArgs }}
