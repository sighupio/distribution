[date_formats]
default_timezone = UTC
[auth]
signout_redirect_url = https://{{ template "grafanaUrl" .spec }}/.pomerium/sign_out
[auth.jwt]
enabled = true
header_name = X-Pomerium-Jwt-Assertion
email_claim = email
jwk_set_url = https://{{ template "pomeriumUrl" .spec }}/.well-known/pomerium/jwks.json
# One Pomerium signs every route it serves with the same key and names the route in the aud claim.
# Without this, Grafana accepts an assertion minted for any other route, so a person that route
# allows reads Grafana. The value is the bare host: Pomerium's getJWTPayloadAud returns the route
# hostname, with no scheme and no trailing slash.
expect_claims = {"aud": "{{ template "grafanaUrl" .spec }}"}
cache_ttl = 60m
username_claim = sub
auto_sign_up = true
[users]
auto_assign_org = true
viewers_can_edit =  true
{{- if and (index .spec.distribution.modules.monitoring "grafana") (index .spec.distribution.modules.monitoring.grafana "usersRoleAttributePath") }}
[auth.jwt]
role_attribute_path = {{ .spec.distribution.modules.monitoring.grafana.usersRoleAttributePath }}
{{- else }}
auto_assign_org_role = Viewer
{{- end }}
