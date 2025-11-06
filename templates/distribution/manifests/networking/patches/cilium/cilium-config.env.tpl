{{- if eq .spec.distribution.common.provider.type "none"  }}
cluster-pool-ipv4-mask-size={{ .spec.distribution.modules.networking.cilium.maskSize }}
{{- if .spec.distribution.modules.networking.cilium.podCidr }}
cluster-pool-ipv4-cidr={{ .spec.distribution.modules.networking.cilium.podCidr }}
{{- else if hasField . "spec.kubernetes.podCidr" }}
cluster-pool-ipv4-cidr={{ .spec.kubernetes.podCidr }}
{{- else }}
cluster-pool-ipv4-cidr={{ .spec.distribution.modules.networking.cilium.podCidr }}
{{- end }}
{{- end }}