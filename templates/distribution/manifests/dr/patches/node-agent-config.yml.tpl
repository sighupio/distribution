# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.


{{- if index .spec.distribution.modules.dr.velero "nodeAgent" }}
{{- if index .spec.distribution.modules.dr.velero.nodeAgent "prepareQueueLength" }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: node-agent-config
  namespace: kube-system
data:
  config.json: |
    {
      "prepareQueueLength": {{ .spec.distribution.modules.dr.velero.nodeAgent.prepareQueueLength }}
    }
{{- end }}
{{- end }}
