# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- if .spec.distribution.modules.auth.oidcKubernetesAuth.enabled }}
clusterName: "{{ .metadata.name }}"
apiServerURL: "https://{{ .spec.kubernetes.controlPlaneAddress }}"
authorizeURL: "https://{{ template "dexUrl" .spec }}/auth"
{{- if index .spec.distribution.modules.auth.oidcKubernetesAuth "trustedCA" }}
trustedCAPath: "/tls/ca.crt"
{{- end }}
tokenURL: "https://{{ template "dexUrl" .spec }}/token"
clientID: "{{ .spec.distribution.modules.auth.oidcKubernetesAuth.clientID }}"
clientSecret: "{{ .spec.distribution.modules.auth.oidcKubernetesAuth.clientSecret }}"
redirectURL: "https://{{ template "gangplankUrl" .spec }}/callback"
{{- if index .spec.distribution.modules.auth.oidcKubernetesAuth "scopes" }}
scopes: 
{{ .spec.distribution.modules.auth.oidcKubernetesAuth.scopes | toYaml | indent 10 }}
{{- else }}
scopes: ["openid", "profile", "email", "offline_access", "groups"]
{{- end }}
{{- if index .spec.distribution.modules.auth.oidcKubernetesAuth "usernameClaim" }}
usernameClaim: "{{ .spec.distribution.modules.auth.oidcKubernetesAuth.usernameClaim }}"
{{- else }}
usernameClaim: "email"
{{- end }}
{{- if index .spec.distribution.modules.auth.oidcKubernetesAuth "emailClaim" }}
emailClaim: "{{ .spec.distribution.modules.auth.oidcKubernetesAuth.emailClaim }}"
{{- else }}
emailClaim: "email"
{{- end }}
{{- if index .spec.distribution.modules.auth.oidcKubernetesAuth "removeCAFromKubeconfig" }}
removeCAFromKubeconfig: {{ .spec.distribution.modules.auth.oidcKubernetesAuth.removeCAFromKubeconfig }}
{{- end }}
{{- if index .spec.distribution.modules.auth.oidcKubernetesAuth "namespace" }}
namespace: "{{ .spec.distribution.modules.auth.oidcKubernetesAuth.namespace }}"
{{- end }}
sessionSecurityKey: "{{ .spec.distribution.modules.auth.oidcKubernetesAuth.sessionSecurityKey }}"
{{- end }}