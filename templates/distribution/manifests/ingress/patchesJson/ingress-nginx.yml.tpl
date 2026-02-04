# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $nginxTls := index .spec.distribution.modules.ingress.nginx "tls" }}
{{- if and $nginxTls (eq $nginxTls.provider "secret") }}
- op: add
  path: /spec/template/spec/containers/0/args/-
  value: "--default-ssl-certificate=ingress-nginx/ingress-nginx-global-tls-cert"
{{- end }}
