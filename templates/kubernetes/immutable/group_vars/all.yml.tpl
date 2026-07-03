# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.
---
# Intentionally empty. The immutable.yaml version vars now render inline in hosts.yaml so a user
# override in furyctl.yaml wins (a group_vars/all.yml file outranks inline inventory vars and would
# silently shadow it). Rendered empty rather than deleted so a stale file from a previous furyctl
# version is overwritten on re-apply.
