{{- if eq .spec.distribution.modules.logging.loki.backend "minio" }}
MINIO_ACCESS_KEY={{ .spec.distribution.modules.logging.minio.rootUser.username }}
MINIO_SECRET_KEY={{ .spec.distribution.modules.logging.minio.rootUser.password }}
{{- end }}
{{- if eq .spec.distribution.modules.logging.loki.backend "externalEndpoint" }}
MINIO_ACCESS_KEY={{ .spec.distribution.modules.logging.loki.externalEndpoint.accessKeyId }}
MINIO_SECRET_KEY={{ .spec.distribution.modules.logging.loki.externalEndpoint.secretAccessKey }}
{{- end }}
