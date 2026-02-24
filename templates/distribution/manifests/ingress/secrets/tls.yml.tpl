# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $haproxyType := .spec.distribution.modules.ingress.haproxy.type }}
{{/* NGINX TLS secret */}}
{{- if and (ne .spec.distribution.modules.ingress.nginx.type "none") (eq .spec.distribution.modules.ingress.nginx.tls.provider "secret") }}
---
apiVersion: v1
kind: Secret
metadata:
  name: ingress-nginx-global-tls-cert
  namespace: ingress-nginx
type: kubernetes.io/tls
data:
  ca.crt: {{ .spec.distribution.modules.ingress.nginx.tls.secret.ca | b64enc }}
  tls.crt: {{ .spec.distribution.modules.ingress.nginx.tls.secret.cert | b64enc }}
  tls.key: {{ .spec.distribution.modules.ingress.nginx.tls.secret.key | b64enc }}
{{- end }}
{{/* HAProxy TLS secret */}}
{{- if and (ne $haproxyType "none") (eq .spec.distribution.modules.ingress.haproxy.tls.provider "secret") }}
---
apiVersion: v1
kind: Secret
metadata:
  name: haproxy-ingress-global-tls-cert
  namespace: ingress-haproxy
type: kubernetes.io/tls
data:
  ca.crt: {{ .spec.distribution.modules.ingress.haproxy.tls.secret.ca | b64enc }}
  tls.crt: {{ .spec.distribution.modules.ingress.haproxy.tls.secret.cert | b64enc }}
  tls.key: {{ .spec.distribution.modules.ingress.haproxy.tls.secret.key | b64enc }}
{{- end }}
