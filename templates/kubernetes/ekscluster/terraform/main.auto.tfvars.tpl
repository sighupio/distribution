/**
 * Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
 * Use of this source code is governed by a BSD-style
 * license that can be found in the LICENSE file.
 */

cluster_name = {{ .metadata.name | quote }}
tags = {
{{- range $key, $value := .spec.tags }}
  {{ $key }} = "{{ $value }}"
{{- end }}
}

{{- if hasKeyAny .spec.kubernetes "logsTypes" }}
cluster_enabled_log_types = {{ toJson .spec.kubernetes.logsTypes }}
{{- end }}
kubectl_path = {{ .kubernetes.kubectlPath | quote }}
cluster_version = {{ .kubernetes.version | quote }}
cluster_endpoint_private_access = {{ .spec.kubernetes.apiServer.privateAccess }}

{{- $privateAccessCidrs := .spec.kubernetes.apiServer.privateAccessCidrs }}
{{- if hasKeyAny .infrastructure "clusterEndpointPrivateAccessCidrs" }}
    {{- $privateAccessCidrs = append $privateAccessCidrs .infrastructure.clusterEndpointPrivateAccessCidrs }}
{{- end }}
cluster_endpoint_private_access_cidrs = {{ toJson ($privateAccessCidrs | uniq) }}
cluster_endpoint_public_access = {{ .spec.kubernetes.apiServer.publicAccess }}

{{- $publicAccessCidrs := .spec.kubernetes.apiServer.publicAccessCidrs }}
{{- if eq (len $publicAccessCidrs) 0 }}
    {{- $publicAccessCidrs = append $publicAccessCidrs "0.0.0.0/0" }}
{{- end}}
cluster_endpoint_public_access_cidrs = {{ toJson ($publicAccessCidrs | uniq) }}

{{- if not (hasKeyAny .spec.kubernetes "serviceIpV4Cidr") }}
cluster_service_ipv4_cidr = null
{{- else }}
cluster_service_ipv4_cidr = {{ .spec.kubernetes.serviceIpV4Cidr | quote }}
{{- end }}
node_pools_launch_kind = {{ .spec.kubernetes.nodePoolsLaunchKind | quote }}
node_pools_global_ami_type = {{ .spec.kubernetes.nodePoolGlobalAmiType | quote }}

{{- if hasKeyAny .spec.kubernetes "logRetentionDays" }}
cluster_log_retention_days = {{ .spec.kubernetes.logRetentionDays }}
{{- end }}

{{- if hasKeyAny .infrastructure "vpcId" }}
vpc_id = {{ .infrastructure.vpcId | quote }}
{{- else }}
vpc_id = {{ .spec.kubernetes.vpcId | quote }}
{{- end }}

{{- $subnets := list }}
{{- if hasKeyAny .infrastructure "subnets" }}
    {{- $subnets = .infrastructure.subnets }}
{{- else }}
    {{- $subnets = .spec.kubernetes.subnetIds }}
{{- end }}
subnets = {{ toJson $subnets }}
ssh_public_key = {{ .spec.kubernetes.nodeAllowedSshPublicKey | quote }}

{{- if hasKeyAny .spec.kubernetes "awsAuth" }}
    {{- if gt (len .spec.kubernetes.awsAuth.additionalAccounts) 0 }}
eks_map_accounts = {{ toJson .spec.kubernetes.awsAuth.additionalAccounts }}
    {{- end }}

    {{- if gt (len .spec.kubernetes.awsAuth.users) 0 }}
        {{- $users := list }}

        {{- range $u := .spec.kubernetes.awsAuth.users }}
            {{- $currUser := dict "username" $u.username "userarn" $u.userarn "groups" $u.groups }}
            {{- $users = append $users $currUser }}
        {{- end }}
eks_map_users = {{ toPrettyJson $users | join ","}}
    {{- end }}

    {{- if gt (len .spec.kubernetes.awsAuth.roles) 0 }}
        {{- $roles := list }}

        {{- range $r := .spec.kubernetes.awsAuth.roles }}
            {{- $currRole := dict "username" $r.username "rolearn" $r.rolearn "groups" $r.groups }}
            {{- $roles = append $roles $currRole }}
        {{- end }}
eks_map_roles = {{ toPrettyJson $roles | join "," }}
    {{- end }}
{{- end }}

{{- if hasKeyAny .spec.kubernetes "clusterIAMRoleNamePrefixOverride" }}
cluster_iam_role_name_prefix_override = {{ .spec.kubernetes.clusterIAMRoleNamePrefixOverride | quote }}
{{- end }}

{{- if hasKeyAny .spec.kubernetes "workersIAMRoleNamePrefixOverride" }}
workers_iam_role_name_prefix_override = {{ .spec.kubernetes.workersIAMRoleNamePrefixOverride | quote }}
{{- end }}

{{- if gt (len .spec.kubernetes.nodePools) 0 }}
    {{- $nodePools := list }}

    {{- range $np := .spec.kubernetes.nodePools }}
        {{- $currNodePool := dict "name" $np.name "version" nil "min_size" $np.size.min "max_size" $np.size.max "instance_type" $np.instance.type "spot_instance" false "volume_size" 35 "subnets" nil "additional_firewall_rules" nil "labels" nil "taints" nil "tags" nil }}

        {{- if hasKeyAny $np "type" }}
            {{- $currNodePool = mergeOverwrite $currNodePool (dict "type" $np.type) }}
        {{- end}}

        {{- if hasKeyAny $np "ami" }}
            {{- if and (eq $np.type "self-managed") (hasKeyAny $np.ami "id") (not (hasKeyAny $np.ami "type")) }}
                {{- $currNodePool = mergeOverwrite $currNodePool (dict "ami_id" $np.ami.id "ami_owners" (list $np.ami.owner))  }}
            {{- else if and (hasKeyAny $np.ami "type") (not (hasKeyAny $np.ami "id")) }}
                {{- $currNodePool = mergeOverwrite $currNodePool (dict "ami_type" $np.ami.type) }}
            {{- end }}
        {{- end }}

        {{- if hasKeyAny $np.instance "spot" }}
            {{- $currNodePool = mergeOverwrite $currNodePool (dict "spot_instance" $np.instance.spot) }}
        {{- end }}

        {{- if hasKeyAny $np "containerRuntime" }}
            {{- $currNodePool = mergeOverwrite $currNodePool (dict "container_runtime" $np.containerRuntime) }}
        {{- end }}

        {{- if hasKeyAny $np.instance "maxPods" }}
            {{- $currNodePool = mergeOverwrite $currNodePool (dict "max_pods" $np.instance.maxPods) }}
        {{- end }}

        {{- if hasKeyAny $np.instance "volumeSize" }}
            {{- $currNodePool = mergeOverwrite $currNodePool (dict "volume_size" $np.instance.volumeSize) }}
        {{- end }}

        {{- if hasKeyAny $np.instance "volumeType" }}
            {{- $currNodePool = mergeOverwrite $currNodePool (dict "volume_type" $np.instance.volumeType) }}
        {{- end }}

        {{- if and (hasKeyAny $np "subnetIds") (gt (len $np.subnetIds) 0) }}
            {{- $currNodePool = mergeOverwrite $currNodePool (dict "subnets" $np.subnetIds) }}
        {{- end }}

        {{- if hasKeyAny $np "additionalFirewallRules" }}
            {{- $additionalFirewallRules := dict }}

            {{- if and (hasKeyAny $np.additionalFirewallRules "cidrBlocks") (gt (len $np.additionalFirewallRules.cidrBlocks) 0)}}
                {{- $cidrBlocks := list }}

                {{- range $c := $np.additionalFirewallRules.cidrBlocks }}
                    {{- $currCidrBlock := dict "description" $c.name "type" $c.type "protocol" $c.protocol "from_port" $c.ports.from "to_port" $c.ports.to "tags" (dict) "cidr_blocks" ($c.cidrBlocks | uniq) }}

                    {{- if hasKeyAny $c "tags" }}
                        {{- $tags := dict }}

                        {{- range $k, $v := $c.tags }}
                            {{- $tags = mergeOverwrite $tags (dict $k $v) }}
                        {{- end }}

                        {{- $currCidrBlock = mergeOverwrite $currCidrBlock (dict "tags" $tags) }}
                    {{- end }}

                    {{- $cidrBlocks = append $cidrBlocks $currCidrBlock }}
                {{- end }}

                {{- $additionalFirewallRules = mergeOverwrite $additionalFirewallRules (dict "cidr_blocks" $cidrBlocks) }}
            {{- end }}

            {{- if and (hasKeyAny $np.additionalFirewallRules "sourceSecurityGroupId") (gt (len $np.additionalFirewallRules.sourceSecurityGroupId) 0)}}
                {{- $sourceSecurityGroupId := list }}

                {{- range $s := $np.additionalFirewallRules.sourceSecurityGroupId }}
                    {{- $currSourceSecurityGroupId := dict "description" $s.name "type" $s.type "protocol" $s.protocol "from_port" $s.ports.from "to_port" $s.ports.to "tags" (dict) "source_security_group_id" $s.sourceSecurityGroupId }}

                    {{- if hasKeyAny $s "tags" }}
                        {{- $tags := dict }}

                        {{- range $k, $v := $s.tags }}
                            {{- $tags = mergeOverwrite $tags (dict $k $v) }}
                        {{- end }}

                        {{- $currSourceSecurityGroupId = mergeOverwrite $currSourceSecurityGroupId (dict "tags" $tags) }}
                    {{- end }}

                    {{- $sourceSecurityGroupId = append $sourceSecurityGroupId $currSourceSecurityGroupId }}
                {{- end }}

                {{- $additionalFirewallRules = mergeOverwrite $additionalFirewallRules (dict "source_security_group_id" $sourceSecurityGroupId) }}
            {{- end }}

            {{- if and (hasKeyAny $np.additionalFirewallRules "self") (gt (len $np.additionalFirewallRules.self) 0)}}
                {{- $self := list }}

                {{- range $s := $np.additionalFirewallRules.self }}
                    {{- $currSelf := dict "description" $s.name "type" $s.type "protocol" $s.protocol "from_port" $s.ports.from "to_port" $s.ports.to "tags" (dict) "self" $s.self }}

                    {{- if hasKeyAny $s "tags" }}
                        {{- $tags := dict }}

                        {{- range $k, $v := $s.tags }}
                            {{- $tags = mergeOverwrite $tags (dict $k $v) }}
                        {{- end }}

                        {{- $currSelf = mergeOverwrite $currSelf (dict "tags" $tags) }}
                    {{- end }}

                    {{- $self = append $self $currSelf }}
                {{- end }}

                {{- $additionalFirewallRules = mergeOverwrite $additionalFirewallRules (dict "self" $self) }}
            {{- end }}

            {{- $currNodePool = mergeOverwrite $currNodePool (dict "additional_firewall_rules" $additionalFirewallRules) }}
        {{- end }}

        {{- if and (hasKeyAny $np "labels") (gt (len $np.labels) 0) }}
            {{- $labels := dict }}

            {{- range $k, $v := $np.labels }}
                {{- $labels = mergeOverwrite $labels (dict $k $v) }}
            {{- end }}

            {{- $currNodePool = mergeOverwrite $currNodePool (dict "labels" $labels) }}
        {{- end }}

        {{- if and (hasKeyAny $np "taints") (gt (len $np.taints) 0) }}
            {{- $currNodePool = mergeOverwrite $currNodePool (dict "taints" $np.taints) }}
        {{- end }}

        {{- if and (hasKeyAny $np "tags") (gt (len $np.tags) 0) }}
            {{- $tags := dict }}

            {{- range $k, $v := $np.tags }}
                {{- $tags = mergeOverwrite $tags (dict $k $v) }}
            {{- end }}

            {{- $currNodePool = mergeOverwrite $currNodePool (dict "tags" $tags) }}
        {{- end }}

        {{- $nodePools = append $nodePools $currNodePool }}
    {{- end }}
node_pools = {{ toPrettyJson $nodePools }}
{{- end }}
