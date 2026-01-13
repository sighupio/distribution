# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

{{- $stateConfig := dict }}
{{- if index .spec.toolsConfiguration "opentofu" }}
  {{- $stateConfig = .spec.toolsConfiguration.opentofu.state }}
{{- else }}
  {{- $stateConfig = .spec.toolsConfiguration.terraform.state }}
{{- end }}

terraform {
  backend "s3" {
    bucket = "{{ $stateConfig.s3.bucketName }}"
    key    = "{{ $stateConfig.s3.keyPrefix }}/distribution.json"
    region = "{{ $stateConfig.s3.region }}"

    {{- if index $stateConfig.s3 "skipRegionValidation" }}
      skip_region_validation = {{ default false $stateConfig.s3.skipRegionValidation }}
    {{- end }}
  }
}

provider "aws" {
  region = "{{ .spec.region }}"
  default_tags {
    tags = {
      {{- range $k, $v := .spec.tags }}
      {{ $k }} = "{{ $v }}"
      {{- end}}
    }
  }
}

provider "aws" {
  alias = "velero"
  region = "{{ .spec.distribution.modules.dr.velero.eks.region }}"
  default_tags {
     tags = {
       {{- range $k, $v := .spec.tags }}
       {{ $k }} = "{{ $v }}"
       {{- end}}
     }
   }
}

data "aws_eks_cluster" "this" {
  name = "{{ .metadata.name }}"
}
