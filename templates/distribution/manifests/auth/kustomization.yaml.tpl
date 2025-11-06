# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $vendorPrefix := print "../" .spec.distribution.common.relativeVendorPath }}

---
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

{{- if eq .spec.distribution.modules.auth.provider.type "sso" }}
resources:
  - {{ print $vendorPrefix "/modules/auth/katalog/dex" }}
  - {{ print $vendorPrefix "/modules/auth/katalog/pomerium" }}
{{- if .spec.distribution.modules.auth.oidcKubernetesAuth.enabled }}
  - {{ print $vendorPrefix "/modules/auth/katalog/gangplank" }}
{{- end }}
{{- if ne .spec.distribution.modules.ingress.nginx.type "none" }}
  - resources/ingress-infra.yml
{{- end }}
{{- if ne .spec.distribution.modules.auth.oidcTrustedCA "" }}
  - secrets/oidc-trusted-ca.yml
  - secrets/overlays/kube-system-ca
{{- end }}
{{ if eq .spec.distribution.common.networkPoliciesEnabled true }}
  - policies
{{- end }}

patches:
  - path: patches/infra-nodes.yml
  - path: patches/pomerium-ingress.yml
{{- if ne .spec.distribution.modules.auth.oidcTrustedCA "" }}
  - path: patches/pomerium-trusted-ca.yml
  - path: patches/dex-trusted-ca.yml
{{- end }}
{{- if and .spec.distribution.modules.auth.oidcKubernetesAuth.enabled (ne .spec.distribution.modules.auth.oidcTrustedCA "") }}
  - path: patches/gangplank-trusted-ca.yml
{{- end }}
configMapGenerator:
  - name: pomerium
    behavior: replace
    envs:
      - resources/pomerium-config.env
  - name: pomerium-policy
    behavior: replace
    files:
      - policy.yml=resources/pomerium-policy.yml

secretGenerator:
  - name: dex
    namespace: kube-system
    files:
      - config.yml=secrets/dex.yml
  - name: pomerium-env
    behavior: replace
    envs:
      - secrets/pomerium.env
{{- if .spec.distribution.modules.auth.oidcKubernetesAuth.enabled }}
  - name: gangplank
    namespace: kube-system
    files:
      - gangplank.yml=secrets/gangplank.yml
{{- end }}
{{- end }}



{{- if eq .spec.distribution.modules.auth.provider.type "basicAuth" }}

resources:
  - secrets/basic-auth.yml
{{- if .spec.distribution.modules.auth.oidcKubernetesAuth.enabled }}
  - {{ print $vendorPrefix "/modules/auth/katalog/dex" }}
  - {{ print $vendorPrefix "/modules/auth/katalog/gangplank" }}
  - resources/ingress-infra.yml
{{- if ne .spec.distribution.modules.auth.oidcTrustedCA "" }}
  - secrets/overlays/kube-system-ca
{{- end }}
{{- end }}

{{- if .spec.distribution.modules.auth.oidcKubernetesAuth.enabled }}
secretGenerator:
  - name: dex
    namespace: kube-system
    files:
      - config.yml=secrets/dex.yml
  - name: gangplank
    namespace: kube-system
    files:
      - gangplank.yml=secrets/gangplank.yml

patches:
  - path: patches/infra-nodes.yml
{{- if ne .spec.distribution.modules.auth.oidcTrustedCA "" }}
  - path: patches/gangplank-trusted-ca.yml
  - path: patches/dex-trusted-ca.yml
{{- end }}
{{- end }}

{{- end }}

{{- if eq .spec.distribution.modules.auth.provider.type "none" }}

{{- if .spec.distribution.modules.auth.oidcKubernetesAuth.enabled }}
resources:
  - {{ print $vendorPrefix "/modules/auth/katalog/dex" }}
  - {{ print $vendorPrefix "/modules/auth/katalog/gangplank" }}
  - resources/ingress-infra.yml
{{- if ne .spec.distribution.modules.auth.oidcTrustedCA "" }}
  - secrets/overlays/kube-system-ca
{{- end }}
{{- end }}

{{- if .spec.distribution.modules.auth.oidcKubernetesAuth.enabled }}
secretGenerator:
  - name: dex
    namespace: kube-system
    files:
      - config.yml=secrets/dex.yml
  - name: gangplank
    namespace: kube-system
    files:
      - gangplank.yml=secrets/gangplank.yml

patches:
  - path: patches/infra-nodes.yml
{{- if ne .spec.distribution.modules.auth.oidcTrustedCA "" }}
  - path: patches/gangplank-trusted-ca.yml
  - path: patches/dex-trusted-ca.yml
{{- end }}
{{- end }}

{{- end }}


