# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $certManagerArgs := dict "module" "ingress" "package" "certManager" "spec" .spec -}}
{{- $nginxArgs := dict "module" "ingress" "package" "nginx" "spec" .spec -}}
{{- $haproxyArgs := dict "module" "ingress" "package" "haproxy" "spec" .spec -}}
{{- $dnsArgs := dict "module" "ingress" "package" "dns"  "spec" .spec -}}
{{- $forecastleArgs := dict "module" "ingress" "package" "forecastle" "spec" .spec -}}

{{- $haproxy := index .spec.distribution.modules.ingress "haproxy" }}
{{- $haproxyType := "none" }}
{{- if and $haproxy (index $haproxy "type") }}
  {{- $haproxyType = $haproxy.type }}
{{- end }}
{{- $byoic := index .spec.distribution.modules.ingress "byoic" }}
{{- $isBYOIC := and $byoic (index $byoic "enabled") $byoic.enabled }}
{{- $hasAnyIngress := or (ne .spec.distribution.modules.ingress.nginx.type "none") (ne $haproxyType "none") $isBYOIC }}

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cert-manager
  namespace: cert-manager
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $certManagerArgs }}
      tolerations:
        {{ template "tolerations" $certManagerArgs }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cert-manager-cainjector
  namespace: cert-manager
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $certManagerArgs }}
      tolerations:
        {{ template "tolerations" $certManagerArgs }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cert-manager-webhook
  namespace: cert-manager
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $certManagerArgs }}
      tolerations:
        {{ template "tolerations" $certManagerArgs }}
{{- if $hasAnyIngress }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: forecastle
  namespace: forecastle
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $forecastleArgs }}
      tolerations:
        {{ template "tolerations" $forecastleArgs }}
{{- end }}
{{ if eq .spec.distribution.modules.ingress.nginx.type "dual" -}}
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ingress-nginx-controller-external
  namespace: ingress-nginx
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $nginxArgs }}
      tolerations:
        {{ template "tolerations" $nginxArgs }}
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ingress-nginx-controller-internal
  namespace: ingress-nginx
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $nginxArgs }}
      tolerations:
        {{ template "tolerations" $nginxArgs }}
{{- else if eq .spec.distribution.modules.ingress.nginx.type "single" -}}
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: ingress-nginx-controller
  namespace: ingress-nginx
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $nginxArgs }}
      tolerations:
        {{ template "tolerations" $nginxArgs }}
{{- end }}
{{ if eq $haproxyType "dual" -}}
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: haproxy-ingress-external
  namespace: ingress-haproxy
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $haproxyArgs }}
      tolerations:
        {{ template "tolerations" $haproxyArgs }}
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: haproxy-ingress-internal
  namespace: ingress-haproxy
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $haproxyArgs }}
      tolerations:
        {{ template "tolerations" $haproxyArgs }}
{{- else if eq $haproxyType "single" -}}
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: haproxy-ingress
  namespace: ingress-haproxy
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $haproxyArgs }}
      tolerations:
        {{ template "tolerations" $haproxyArgs }}
{{- end }}

{{- if eq .spec.distribution.common.provider.type "eks" }}
{{ if or (eq .spec.distribution.modules.ingress.nginx.type "dual") (eq $haproxyType "dual") -}}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: external-dns-public
  namespace: external-dns
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $dnsArgs }}
      tolerations:
        {{ template "tolerations" $dnsArgs }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: external-dns-private
  namespace: external-dns
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $dnsArgs }}
      tolerations:
        {{ template "tolerations" $dnsArgs }}
{{- else if or (eq .spec.distribution.modules.ingress.nginx.type "single") (eq $haproxyType "single") -}}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: external-dns-public
  namespace: external-dns
spec:
  template:
    spec:
      nodeSelector:
        {{ template "nodeSelector" $dnsArgs }}
      tolerations:
        {{ template "tolerations" $dnsArgs }}
{{- end }}
{{- end }}
