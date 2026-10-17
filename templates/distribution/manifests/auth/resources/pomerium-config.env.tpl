# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- define "pomeriumHost" -}}
  {{ if .spec.distribution.modules.auth.overrides.ingresses.pomerium.host -}}
    {{ .spec.distribution.modules.auth.overrides.ingresses.pomerium.host }}
  {{- else -}}
    {{ print "pomerium." .spec.distribution.modules.auth.baseDomain }}
  {{- end }}
{{- end -}}
{{- define "dexHost" -}}
  {{ if .spec.distribution.modules.auth.overrides.ingresses.dex.host -}}
    {{ print "https://" .spec.distribution.modules.auth.overrides.ingresses.dex.host }}
  {{- else -}}
    {{ print "https://login." .spec.distribution.modules.auth.baseDomain }}
  {{- end }}
{{- end -}}
{{ if eq .spec.distribution.modules.auth.provider.type "sso" }}
FORWARD_AUTH_HOST={{ template "pomeriumHost" . }}
AUTHENTICATE_SERVICE_HOST={{ template "pomeriumHost" . }}
FORWARD_AUTH_URL=https://$(FORWARD_AUTH_HOST)
AUTHENTICATE_SERVICE_URL=https://$(AUTHENTICATE_SERVICE_HOST)
AUTOCERT=false
POMERIUM_DEBUG=false
LOG_LEVEL=info

# DEX settings
IDP_CLIENT_ID=pomerium
# See https://docs.pomerium.io/configuration/#identity-provider-name
IDP_PROVIDER=oidc
# IDP_PROVIDER_URL is the url of dex ingress
IDP_PROVIDER_URL={{ template "dexHost" . }}
IDP_SCOPES=openid profile email groups
{{- /* Since Pomerium v0.33 the sign-out handler ignores pomerium_redirect_uri unless the */}}
{{- /* allow_any_sign_out_redirect_uri runtime flag is set, so send every sign-out back to */}}
{{- /* Headlamp: with no session left, Pomerium restarts the OIDC flow (login page). */}}
{{- /* The predicate mirrors utilities/resources/headlamp-ingress.yml.tpl (SSO mode only). */}}
{{- $headlampType := .spec | digAny "distribution" "modules" "utilities" "headlamp" "type" "none" }}
{{- if and (eq .spec.distribution.common.provider.type "none" "immutable") (hasKeyAny .spec "kubernetes") (eq $headlampType "sso") }}

# Send every sign-out back to Headlamp
SIGNOUT_REDIRECT_URL=https://dashboard.{{ .spec.distribution.modules.ingress.baseDomain }}/
{{- end }}
{{ end }}
