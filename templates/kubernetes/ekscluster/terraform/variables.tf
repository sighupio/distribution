/**
 * Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
 * Use of this source code is governed by a BSD-style
 * license that can be found in the LICENSE file.
 */

variable "cluster_name" {
  type        = string
  description = "Unique cluster name. Used in multiple resources to identify your cluster resources"
}

variable "cluster_version" {
  type        = string
  description = "Kubernetes Cluster Version. Look at the cloud providers documentation to discover available versions."
}

variable "cluster_log_retention_days" {
  type    = number
  default = 90
}

variable "cluster_endpoint_private_access" {
  type    = bool
  default = false
}

variable "cluster_endpoint_private_access_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "cluster_endpoint_public_access" {
  type    = bool
  default = false
}

variable "cluster_endpoint_public_access_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "cluster_service_ipv4_cidr" {
  type        = string
  description = "The CIDR block to assign Kubernetes service IP addresses from"
  default     = null
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the Kubernetes cluster will be hosted"
}

variable "subnets" {
  type        = list(any)
  description = "List of subnets where the cluster will be hosted"
}

variable "ssh_public_key" {
  type        = string
  description = "Cluster administrator public ssh key. Used to access cluster nodes with the operator_ssh_user"
}

variable "node_pools" {
  description = "An object list defining node pools configurations"
  type = list(object({
    type              = optional(string, "self-managed") # "eks-managed" or "self-managed"
    name              = string
    ami_id            = optional(string)
    ami_owners        = optional(list(string), ["amazon"])
    ami_type          = optional(string, null)
    version           = optional(string, null) # null to use cluster_version
    min_size          = number
    max_size          = number
    instance_type     = string
    container_runtime = optional(string, "containerd")
    spot_instance     = optional(bool, false)
    max_pods          = optional(number, null) # null to use default upstream configuration
    volume_size       = optional(number, 100)
    volume_type       = optional(string, "gp2")
    subnets           = optional(list(string), null) # null to use default upstream configuration
    labels            = optional(map(string))
    taints            = optional(list(string))
    tags              = optional(map(string))
    target_group_arns = optional(list(string))
    additional_firewall_rules = optional(
      object({
        cidr_blocks = optional(
          list(
            object({
              description = optional(string)
              type        = string
              cidr_blocks = list(string)
              protocol    = string
              from_port   = number
              to_port     = number
              tags        = map(string)
            })
          )
        )
        source_security_group_id = optional(
          list(
            object({
              description              = optional(string)
              type                     = string
              source_security_group_id = string
              protocol                 = string
              from_port                = number
              to_port                  = number
              tags                     = map(string)
            })
          )
        )
        self = optional(
          list(
            object({
              description = optional(string)
              type        = string
              self        = bool
              protocol    = string
              from_port   = number
              to_port     = number
              tags        = map(string)
            })
          )
        )
      })
    )
  }))
  default = []
}

variable "node_pools_launch_kind" {
  type        = string
  description = "Choose if the node pools will use launch_configurations, launch_templates or both"
}

variable "tags" {
  type        = map(any)
  description = "The tags to apply to all resources"
  default     = {}
}

variable "eks_map_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap"
  type        = list(string)

  # example = [
  #   "777777777777",
  #   "888888888888",
  # ]
  default = []
}

variable "eks_map_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap"
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))

  # example = [
  #   {
  #     rolearn  = "arn:aws:iam::66666666666:role/role1"
  #     username = "role1"
  #     groups   = ["system:masters"]
  #   },
  # ]
  default = []
}

variable "eks_map_users" {
  description = "Additional IAM users to add to the aws-auth configmap"
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  # example = [
  #   {
  #     userarn  = "arn:aws:iam::66666666666:user/user1"
  #     username = "user1"
  #     groups   = ["system:masters"]
  #   },
  #   {
  #     userarn  = "arn:aws:iam::66666666666:user/user2"
  #     username = "user2"
  #     groups   = ["system:masters"]
  #   },
  # ]
  default = []
}

variable "kubectl_path" {
  type        = string
  description = "The path to the kubectl binary. By default, the one present in PATH is used"
  default     = "kubectl"
}
variable "cluster_enabled_log_types" {
  description = "List of log types that will be enabled for the EKS cluster. Can be a subset of ['api', 'audit', 'authenticator', 'controllerManager', 'scheduler'] or an empty list."
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  nullable = false
  validation {
    condition     = length(var.cluster_enabled_log_types) == 0 || alltrue([for val in var.cluster_enabled_log_types : contains(["api", "audit", "authenticator", "controllerManager", "scheduler"], val)])
    error_message = "The log type must be one of the following: api, audit, authenticator, controllerManager, scheduler, or the list must be empty."
  }

}

variable "cluster_iam_role_name_prefix_override" {
  description = "The name prefix of the IAM role to use for the EKS cluster. If not set, a name will be generated from the cluster name."
  type        = string
  default     = ""
}

variable "workers_iam_role_name_prefix_override" {
  description = "The name prefix of the IAM role to use for the EKS workers. If not set, a name will be generated from the cluster name."
  type        = string
  default     = ""
}

variable "node_pools_global_ami_type" {
  type        = string
  description = "Global default AMI type used for EKS worker nodes. This will apply to all node pools unless overridden by a specific node pool."
  default     = "alinux2"
  validation {
    condition     = contains(["alinux2", "alinux2023"], var.node_pools_global_ami_type)
    error_message = "The global AMI type must be either 'alinux2' or 'alinux2023'."
  }
}

variable "workers_group_defaults" {
  type = any

  default = {
    metadata_http_endpoint               = "enabled"
    metadata_http_tokens                 = "optional"
    metadata_http_put_response_hop_limit = null
  }
}
