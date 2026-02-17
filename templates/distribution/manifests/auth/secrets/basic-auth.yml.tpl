# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- if eq .spec.distribution.modules.auth.provider.type "basicAuth" -}}
{{- $username := .spec.distribution.modules.auth.provider.basicAuth.username -}}
{{- $password := .spec.distribution.modules.auth.provider.basicAuth.password -}}
{{- $haproxyType := .spec.distribution.modules.ingress.haproxy.type }}
{{- $isBYOIC := .spec.distribution.modules.ingress.byoic.enabled }}
{{- $hasAnyIngress := or (ne .spec.distribution.modules.ingress.nginx.type "none") (ne $haproxyType "none") $isBYOIC }}

{{- /* Check if HAProxy is the active controller for infra ingresses */ -}}
{{- $infrastructureIngressController := index .spec.distribution.modules.ingress "infrastructureIngressController" -}}
{{- $useHAProxyFormat := false -}}
{{- if $infrastructureIngressController -}}
  {{- $useHAProxyFormat = hasPrefix "haproxy" $infrastructureIngressController -}}
{{- else if ne .spec.distribution.modules.ingress.nginx.type "none" -}}
  {{- $useHAProxyFormat = false -}}
{{- else if ne $haproxyType "none" -}}
  {{- $useHAProxyFormat = true -}}
{{- end -}}

{{- $htpasswdFull := htpasswd $username $password -}}
{{- $hashOnly := index (splitList ":" $htpasswdFull) 1 -}}

{{- if eq .spec.distribution.modules.policy.type "gatekeeper" }}
---
apiVersion: v1
kind: Secret
metadata:
  name: basic-auth
  namespace: gatekeeper-system
type: Opaque
stringData:
{{- if $useHAProxyFormat }}
  {{ $username }}: '{{ $hashOnly }}'
{{- else }}
  auth: {{ $htpasswdFull }}
{{- end }}
{{- end }}

{{- if ne .spec.distribution.modules.ingress.nginx.type "none" }}
---
apiVersion: v1
kind: Secret
metadata:
  name: basic-auth
  namespace: ingress-nginx
type: Opaque
stringData:
  auth: {{ $htpasswdFull }}
{{- end }}

{{- if ne $haproxyType "none" }}
---
apiVersion: v1
kind: Secret
metadata:
  name: basic-auth
  namespace: ingress-haproxy
type: Opaque
stringData:
  {{ $username }}: '{{ $hashOnly }}'
{{- end }}

{{- if $hasAnyIngress }}
---
apiVersion: v1
kind: Secret
metadata:
  name: basic-auth
  namespace: forecastle
type: Opaque
stringData:
{{- if $useHAProxyFormat }}
  {{ $username }}: '{{ $hashOnly }}'
{{- else }}
  auth: {{ $htpasswdFull }}
{{- end }}
{{- end }}

{{- if ne .spec.distribution.modules.logging.type "none" }}
{{- if .checks.storageClassAvailable }}
---
apiVersion: v1
kind: Secret
metadata:
  name: basic-auth
  namespace: logging
type: Opaque
stringData:
{{- if $useHAProxyFormat }}
  {{ $username }}: '{{ $hashOnly }}'
{{- else }}
  auth: {{ $htpasswdFull }}
{{- end }}
{{- end }}
{{- end }}

{{- if ne .spec.distribution.modules.monitoring.type "none" }}
---
apiVersion: v1
kind: Secret
metadata:
  name: basic-auth
  namespace: monitoring
type: Opaque
stringData:
{{- if $useHAProxyFormat }}
  {{ $username }}: '{{ $hashOnly }}'
{{- else }}
  auth: {{ $htpasswdFull }}
{{- end }}
{{- end }}

{{ if eq .spec.distribution.modules.networking.type "cilium" }}
---
apiVersion: v1
kind: Secret
metadata:
  name: basic-auth
  namespace: kube-system
type: Opaque
stringData:
{{- if $useHAProxyFormat }}
  {{ $username }}: '{{ $hashOnly }}'
{{- else }}
  auth: {{ $htpasswdFull }}
{{- end }}
{{- end }}
{{- end -}}
