# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- if and .spec.distribution.modules.auth.oidcKubernetesAuth.enabled .spec.distribution.modules.auth.oidcKubernetesAuth.trustedCA }}
---
apiVersion: v1
kind: Secret
metadata:
  name: dex-trusted-ca
  namespace: kube-system
type: Opaque
data:
  ca.crt: {{ .spec.distribution.modules.auth.oidcKubernetesAuth.trustedCA | b64enc }}
{{- end }}
