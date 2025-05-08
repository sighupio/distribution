apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: sd-docs
resources:
  - namespace.yaml
  - deployment.yaml
  - service.yaml
  {{- if ne .spec.distribution.modules.ingress.nginx.type "none" }}
  - ingress.yaml
  {{- end }}
