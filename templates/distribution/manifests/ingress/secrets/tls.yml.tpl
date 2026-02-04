# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $haproxy := index .spec.distribution.modules.ingress "haproxy" }}
{{- $haproxyType := "none" }}
{{- if and $haproxy (index $haproxy "type") }}
  {{- $haproxyType = $haproxy.type }}
{{- end }}
{{/* NGINX TLS secret */}}
{{- $nginxTls := index .spec.distribution.modules.ingress.nginx "tls" }}
{{- if and (ne .spec.distribution.modules.ingress.nginx.type "none") $nginxTls (eq $nginxTls.provider "secret") }}
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
{{- if and (ne $haproxyType "none") $haproxy.tls (eq $haproxy.tls.provider "secret") }}
---
apiVersion: v1
kind: Secret
metadata:
  name: haproxy-ingress-global-tls-cert
  namespace: ingress-haproxy
type: kubernetes.io/tls
data:
  ca.crt: {{ $haproxy.tls.secret.ca | b64enc }}
  tls.crt: {{ $haproxy.tls.secret.cert | b64enc }}
  tls.key: {{ $haproxy.tls.secret.key | b64enc }}
{{- end }}
