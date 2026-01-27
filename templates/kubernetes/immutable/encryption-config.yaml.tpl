{{- if (.spec.kubernetes | digAny "advanced" "encryption" "configuration" false) }}
{{- .spec.kubernetes.advanced.encryption.configuration }}
{{- end }}
