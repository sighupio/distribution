# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

---
apiVersion: velero.io/v1
kind: Schedule
metadata:
  name: manifests
  namespace: kube-system
spec:
  schedule: {{ .spec.distribution.modules.dr.velero.schedules.cron.manifests }}
  template:
    ttl: {{ .spec.distribution.modules.dr.velero.schedules.ttl }}
