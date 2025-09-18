/**
 * Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
 * Use of this source code is governed by a BSD-style
 * license that can be found in the LICENSE file.
 */

terraform {
  backend "s3" {
    bucket = "{{ .spec.toolsConfiguration.terraform.state.s3.bucketName }}"
    key    = "{{ .spec.toolsConfiguration.terraform.state.s3.keyPrefix }}/cluster.json"
    region = "{{ .spec.toolsConfiguration.terraform.state.s3.region }}"

    {{- if index .spec.toolsConfiguration.terraform.state.s3 "skipRegionValidation" }}
      skip_region_validation = {{ default false .spec.toolsConfiguration.terraform.state.s3.skipRegionValidation }}
    {{- end }}
  }

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
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

provider "kubernetes" {
  host                   = data.aws_eks_cluster.fury.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.fury.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.fury.token
  load_config_file       = false
}

module "fury" {
  source = "{{ .kubernetes.installerPath }}"

  cluster_name                          = var.cluster_name
  cluster_version                       = var.cluster_version
  cluster_log_retention_days            = var.cluster_log_retention_days
  {{- if eq .features.logTypesEnabled true }}
  cluster_enabled_log_types             = var.cluster_enabled_log_types
  {{- end }}
  cluster_endpoint_public_access        = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs  = var.cluster_endpoint_public_access_cidrs
  cluster_endpoint_private_access       = var.cluster_endpoint_private_access
  cluster_endpoint_private_access_cidrs = var.cluster_endpoint_private_access_cidrs
  cluster_service_ipv4_cidr             = var.cluster_service_ipv4_cidr
  vpc_id                                = var.vpc_id
  subnets                               = var.subnets
  ssh_public_key                        = var.ssh_public_key
  node_pools                            = var.node_pools
  node_pools_launch_kind                = var.node_pools_launch_kind
  node_pools_global_ami_type            = var.node_pools_global_ami_type
  tags                                  = var.tags
  cluster_iam_role_name                 = var.cluster_iam_role_name_prefix_override
  workers_role_name                     = var.workers_iam_role_name_prefix_override
  workers_group_defaults                = var.workers_group_defaults

  # AWS-specific variables.
  # Enables managing auth using these variables
  eks_map_users    = var.eks_map_users
  eks_map_roles    = var.eks_map_roles
  eks_map_accounts = var.eks_map_accounts

  # ssh_to_nodes_allowed_cidr_blocks = []
}
