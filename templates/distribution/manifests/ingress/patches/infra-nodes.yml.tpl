# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $certManagerArgs := dict "module" "ingress" "package" "certManager" "spec" .spec -}}
{{- $nginxArgs := dict "module" "ingress" "package" "nginx" "spec" .spec -}}
{{- $dnsArgs := dict "module" "ingress" "package" "dns"  "spec" .spec -}}
{{- $forecastleArgs := dict "module" "ingress" "package" "forecastle" "spec" .spec -}}

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
{{- if ne .spec.distribution.modules.ingress.nginx.type "none" }}
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

{{- if eq .spec.distribution.common.provider.type "eks" }}
{{ if eq .spec.distribution.modules.ingress.nginx.type "dual" -}}
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
{{- else if eq .spec.distribution.modules.ingress.nginx.type "single" -}}
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
