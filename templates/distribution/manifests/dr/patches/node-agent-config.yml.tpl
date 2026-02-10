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
