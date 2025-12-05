{{- if eq .spec.distribution.common.provider.type "none"  }}
cluster-pool-ipv4-mask-size={{ .spec.distribution.modules.networking.cilium.maskSize }}
  {{- if index .spec "kubernetes" }}
    {{- if index .spec.kubernetes "podCidr" }}
      {{- if .spec.distribution.modules.networking.cilium.podCidr }}
cluster-pool-ipv4-cidr={{ .spec.distribution.modules.networking.cilium.podCidr }}
      {{- else }}
cluster-pool-ipv4-cidr={{ .spec.kubernetes.podCidr }}
      {{- end }}
    {{- else }}
cluster-pool-ipv4-cidr={{ .spec.distribution.modules.networking.cilium.podCidr }}
    {{- end }}
    {{- /* We assume that kubeProxy is enabled by default */}}
    {{- /* The `digAny` condition needs to be specified exactly as written below to properly check if the field has been populated */}}
    {{- if not (.spec | digAny "kubernetes" "advanced" "kubeProxy" "enabled" true) }}
kube-proxy-replacement=true
    {{- end }}
  {{- end }}
{{- end }}
