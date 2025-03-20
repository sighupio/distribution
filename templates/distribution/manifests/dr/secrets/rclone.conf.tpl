# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- if eq .spec.distribution.modules.dr.etcdBackup.type "all" "s3" }}
[s3]
type = s3
access_key_id = {{ .spec.distribution.modules.dr.etcdBackup.s3.accessKeyId }}
secret_access_key = {{ .spec.distribution.modules.dr.etcdBackup.s3.secretAccessKey }}
endpoint = {{ ternary "http" "https" .spec.distribution.modules.dr.etcdBackup.s3.insecure }}://{{ .spec.distribution.modules.dr.etcdBackup.s3.endpoint }}
force_path_style = true
{{- end}}
