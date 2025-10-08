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
    {{/* Set kube-proxy-replacement only if kube-proxy is disabled */}}
    {{- if and (hasKeyAny .spec.kubernetes "advanced") (hasKeyAny .spec.kubernetes.advanced "kubeProxy") (not (index .spec.kubernetes.advanced.kubeProxy "enabled")) }}
kube-proxy-replacement=true
    {{- end }}
  {{- end }}
{{- end }}
