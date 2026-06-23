# Copyright (c) 2026 SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

[defaults]
inventory = hosts.yaml
host_key_checking = False
roles_path = ../vendor/installers/immutable/roles
timeout = 10
callback_result_format = yaml
bin_ansible_callbacks = True
{{ .spec | digAny "toolsConfiguration" "ansible" "config" "" }}
