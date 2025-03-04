{{- if and (index .spec.distribution.modules.dr "etcdBackup") (.spec.distribution.modules.dr.etcdBackup.s3)}}
[minio]
type = s3
provider = Minio
env_auth = false
access_key_id = {{ .spec.distribution.modules.dr.etcdBackup.s3.accessKeyId }}
secret_access_key = {{ .spec.distribution.modules.dr.etcdBackup.s3.secretAccessKey }}
region = us-east-1
endpoint = {{ .spec.distribution.modules.dr.etcdBackup.s3.endpoint }}
location_constraint =
server_side_encryption =
{{- end}}
