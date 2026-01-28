{{- $providerType := .spec.distribution.common.provider.type }}

{{- $podCIDR := "" }}
{{- if and (eq $providerType "none") (index .spec.kubernetes) }}{{/* OnPremises */}}
{{- $podCIDR = .spec.kubernetes.podCidr }}
{{- end }}
{{- if eq $providerType "immutable" }}
{{- $podCIDR = .spec.kubernetes.networking.podCIDR }}
{{- end }}
{{- if .spec.distribution.modules.networking.cilium.podCidr }}
{{- $podCIDR = .spec.distribution.modules.networking.cilium.podCidr }}
{{- end }}

cluster-pool-ipv4-mask-size={{ .spec.distribution.modules.networking.cilium.maskSize }}
cluster-pool-ipv4-cidr={{ $podCIDR }}
{{- /* We assume that kubeProxy is enabled by default */}}
{{- /* The `digAny` condition needs to be specified exactly as written below to properly check if the field has been populated */}}
{{- if not (.spec | digAny "kubernetes" "advanced" "kubeProxy" "enabled" true) }}
kube-proxy-replacement=true
{{- end }}