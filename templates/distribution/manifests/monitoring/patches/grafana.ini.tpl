[date_formats]
default_timezone = UTC
[auth]
signout_redirect_url = https://{{ template "grafanaUrl" .spec }}/.pomerium/sign_out
[auth.jwt]
enabled = true
header_name = X-Pomerium-Jwt-Assertion
email_claim = email
jwk_set_url = https://{{ template "pomeriumUrl" .spec }}/.well-known/pomerium/jwks.json
cache_ttl = 60m
username_claim = sub
auto_sign_up = true
[users]
auto_assign_org = true
viewers_can_edit =  true
{{- if hasField . "spec.distribution.modules.monitoring.grafana.usersRoleAttributePath" }}
[auth.jwt]
role_attribute_path = {{ .spec.distribution.modules.monitoring.grafana.usersRoleAttributePath }}
{{- else }}
auto_assign_org_role = Viewer
{{- end }}
