# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- if eq .spec.distribution.modules.ingress.haproxy.tls.provider "secret" }}
# Note: this assumes HAProxy package has --default-ssl-certificate as args/0. If katalog args order changes, this patch will break.
- op: replace
  path: /spec/template/spec/containers/0/args/0
  value: "--default-ssl-certificate=ingress-haproxy/haproxy-ingress-global-tls-cert"
{{- end }}
