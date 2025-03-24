# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

module "eks_addons" {
  source       = "{{ print .spec.distribution.common.relativeVendorPath "/modules/aws/modules/eks-addons" }}"
  cluster_name = "{{ .metadata.name }}"
  ebs_csi_driver = {
    service_account_role_arn = module.ebs_csi_driver_iam_role.ebs_csi_driver_iam_role_arn
    configuration_values = jsonencode({
      controller =  {
          tolerations = [
            {{- range $toleration := .spec.distribution.common.tolerations }}
            {
              {{- if $toleration.key }}
              key = "{{ $toleration.key }}"
              {{- end }}
              {{- if $toleration.value }}
              value = "{{ $toleration.value }}"
              {{- end }}
              {{- if $toleration.effect }}
              effect = "{{ $toleration.effect }}"
              {{- end }}
            }
          {{- end }}
          ]
          nodeSelector = {
            {{- range $k,$v := .spec.distribution.common.nodeSelector }}
              "{{ $k }}" = "{{ $v }}"
            {{- end }}
          }
        }
    })
  }
  coredns = {
    configuration_values = jsonencode({
      tolerations = [
        {{- range $toleration := .spec.distribution.common.tolerations }}
        {
          {{- if $toleration.key }}
          key = "{{ $toleration.key }}"
          {{- end }}
          {{- if $toleration.value }}
          value = "{{ $toleration.value }}"
          {{- end }}
          {{- if $toleration.effect }}
          effect = "{{ $toleration.effect }}"
          {{- end }}
        }
      {{- end }}
      ]
      nodeSelector = {
        {{- range $k,$v := .spec.distribution.common.nodeSelector }}
          "{{ $k }}" = "{{ $v }}"
        {{- end }}
      }
    })
  }
  snapshot_controller = {
    configuration_values = jsonencode({
      tolerations = [
        {{- range $toleration := .spec.distribution.common.tolerations }}
        {
          {{- if $toleration.key }}
          key = "{{ $toleration.key }}"
          {{- end }}
          {{- if $toleration.value }}
          value = "{{ $toleration.value }}"
          {{- end }}
          {{- if $toleration.effect }}
          effect = "{{ $toleration.effect }}"
          {{- end }}
        }
      {{- end }}
      ]
      nodeSelector = {
        {{- range $k,$v := .spec.distribution.common.nodeSelector }}
          "{{ $k }}" = "{{ $v }}"
        {{- end }}
      }
    })
  }
}
