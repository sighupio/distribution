# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- if ne .spec.distribution.modules.auth.oidcTrustedCA "" }}
---
apiVersion: v1
kind: Secret
metadata:
  name: oidc-trusted-ca
  namespace: pomerium
type: Opaque
data:
  ca.crt: {{ .spec.distribution.modules.auth.oidcTrustedCA | b64enc }}
{{- end }}
