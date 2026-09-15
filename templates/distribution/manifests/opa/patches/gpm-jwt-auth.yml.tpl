# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- if and (eq .spec.distribution.modules.policy.type "gatekeeper") (eq .spec.distribution.modules.auth.provider.type "sso") }}
---
# Pomerium already identifies the person in front of GPM. From GPM 2.1.0, GPM verifies the assertion
# Pomerium signs, instead of serving every request that reaches it. The GPM Service is reachable from
# every Pod in the cluster, so before this GPM showed the whole cluster's policy status to anything
# that could open a connection to it.
#
# This mode runs no login of its own and holds no session, so it needs no GPM_SECRET_KEY.
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gatekeeper-policy-manager
  namespace: gatekeeper-system
spec:
  template:
    spec:
      containers:
        - name: gatekeeper-policy-manager
          env:
            - name: GPM_AUTH_ENABLED
              value: "JWT"
            - name: GPM_JWT_JWK_SET_URL
              value: "https://{{ template "pomeriumUrl" .spec }}/.well-known/pomerium/jwks.json"
            # The bare route host, with no scheme and no trailing slash: that is what Pomerium puts
            # in the aud claim. GPM refuses to start without it, because one Pomerium signs every
            # route with the same key, so an unchecked audience accepts an assertion minted for a
            # different route and lets the people that route allows read GPM.
            - name: GPM_JWT_AUDIENCE
              value: "{{ template "gpmUrl" .spec }}"
            - name: GPM_JWT_LOGOUT_URL
              value: "https://{{ template "gpmUrl" .spec }}/.pomerium/sign_out"
{{- end }}
