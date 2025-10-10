# Copyright (c) 2022 SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

[defaults]
inventory = hosts.yaml
host_key_checking = False
roles_path = ../vendor/installers/onpremises/roles
timeout = 90
callback_result_format = yaml
bin_ansible_callbacks = True
{{- if and (index .spec.kubernetes "advancedAnsible") (index .spec.kubernetes.advancedAnsible "config") }}
{{ .spec.kubernetes.advancedAnsible.config }}
{{- end }}
