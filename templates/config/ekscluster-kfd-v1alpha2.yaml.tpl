# yaml-language-server: $schema=https://raw.githubusercontent.com/sighupio/fury-distribution/{{.DistributionVersion}}/schemas/public/ekscluster-kfd-v1alpha2.json
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.


# This is a sample configuration file to be used as a starting point. For the
# complete reference of the configuration file schema, please refer to the
# official documentation:
# https://docs.kubernetesfury.com/docs/installation/kfd-configuration/providers/EKSCluster

---
apiVersion: kfd.sighup.io/v1alpha2
kind: EKSCluster
metadata:
  # The name of the cluster, will be also used as a prefix for all the other resources created on AWS
  name: {{.Name}}
spec:
  # This value defines which KFD version will be installed and in consequence the Kubernetes version to use to create the cluster,
  # it supports git tags and branches
  distributionVersion: {{.DistributionVersion}}
  # This sections defines where to store the terraform state files used by furyctl
  toolsConfiguration:
    terraform:
      state:
        s3:
          # This value defines which bucket will be used to store all the states
          bucketName: example-bucket
          # This value defines which folder will be used to store all the states inside the bucket
          keyPrefix: example-cluster/
          # This value defines in which region the bucket is
          region: eu-west-1
  # This value defines in which AWS region the cluster and all the related resources will be created
  region: eu-west-1
  # This map defines which will be the common tags that will be added to all the resources created on AWS
  tags:
    env: "example"
    k8s: "example2"
  # This first section, infrastructure, defines the underlying network and eventual VPN bastions that will be provisioned.
  # If you already have a VPC, you can remove this key from the configuration file
  infrastructure:
    # This key defines the VPC that will be created in AWS
    vpc:
      network:
        # This is the CIDR of the VPC
        cidr: 10.1.0.0/16
        subnetsCidrs:
          # These are the CIRDs for the private subnets, where the nodes, the pods, and the private load balancers will be created
          private:
            - 10.1.0.0/20
            - 10.1.16.0/20
            - 10.1.32.0/20
          # These are the CIDRs for the public subnets, where the public load balancers and the VPN servers will be created
          public:
            - 10.1.48.0/24
            - 10.1.49.0/24
            - 10.1.50.0/24
    # This section defines the creation of VPN bastions
    vpn:
      # The number of instance to create, 0 to skip the creation
      instances: 2
      # The port used by the OpenVPN server
      port: 1194
      # The size of the AWS ec2 instance
      instanceType: t3.micro
      # The size of the disk in GB
      diskSize: 50
      # The username of the account to create in the bastion's operating system
      operatorName: sighup
      # The dhParamsBits size used for the creation of the .pem file that will  be used in the dh openvpn server.conf file
      dhParamsBits: 2048
      # The CIDR that will be used to assign IP addresses to the VPN clients when connected
      vpnClientsSubnetCidr: 172.16.0.0/16
      # ssh access settings
      ssh:
        # The github user name list that will be used to get the ssh public key that will be added as authorized key to the operatorName user
        githubUsersName:
          - johndoe
        # The CIDR enabled in the security group that can access the bastions in SSH
        allowedFromCidrs:
          - 0.0.0.0/0
  # This section describes how the EKS cluster will be created
  kubernetes:
    # This key contains the ssh public key that can connect to the nodes via SSH using the ec2-user user
    nodeAllowedSshPublicKey: "ssh-ed25519 XYZ"
    # Either `launch_configurations`, `launch_templates` or `both`. For new clusters use `launch_templates`, for existing cluster you'll need to migrate from `launch_configurations` to `launch_templates` using `both` as interim.
    nodePoolsLaunchKind: "launch_templates"
    # Global default AMI type used for EKS worker nodes. This will apply to all node pools unless overridden by a specific node pool. Valid values are: `alinux2`, `alinux2023`
    nodePoolGlobalAmiType: "alinux2"
    # Optional Kubernetes Cluster log retention in days. Defaults to 90 days.
    # logRetentionDays: 90
    # This map defines the access to the Kubernetes API server
    apiServer:
      privateAccess: true
      publicAccess: false
      privateAccessCidrs: ['0.0.0.0/0']
      publicAccessCidrs: ['0.0.0.0/0']
    # This array contains the definition of the nodepools in the cluster
    nodePools:
        # This is the name of the nodepool
      - name: infra
        type: self-managed
        # This map defines the max and min number of nodes in the nodepool autoscaling group
        size:
          min: 1
          max: 3
        # This map defines the characteristics of the instance that will be used in the node pool
        instance:
          # The instance type
          type: t3.xlarge
          # If the instance is a spot instance
          spot: false
          # The instance disk size in GB
          volumeSize: 50
          # The instance disk type
          volumeType: gp2
        # This optional array defines additional target groups to attach to the instances in the node pool
        #attachedTargetGroups:
        #  - arn:aws:elasticloadbalancing:eu-west-1:123456789012:targetgroup/example-external-nginx/0123456789abcdee
        #  - arn:aws:elasticloadbalancing:eu-west-1:123456789012:targetgroup/example-internal-nginx/0123456789abcdef
        # Kubernetes labels that will be added to the nodes
        labels:
          nodepool: infra
          node.kubernetes.io/role: infra
        # Kubernetes taints that will be added to the nodes
        taints:
          - node.kubernetes.io/role=infra:NoSchedule
        # AWS tags that will be added to the ASG and EC2 instances, the example shows the labels needed by cluster autoscaler
        tags:
          k8s.io/cluster-autoscaler/node-template/label/nodepool: "infra"
          k8s.io/cluster-autoscaler/node-template/label/node.kubernetes.io/role: "infra"
        # Optional additional firewall rules that will be attached to the nodes
        #additionalFirewallRules:
        #    # The name of the rule
        #  - name: traffic_80_from_172_31_0_0_16
        #    # The type of the rule, can be ingress or egress
        #    type: ingress
        #    # The CIDR blocks for the FW rule. At the moment the first item of the list will be used, others will be ignored. See https://github.com/sighupio/fury-eks-installer/issues/46
        #    cidrBlocks:
        #      - 172.31.0.0/16
        #    # The protocol
        #    protocol: TCP
        #    # The ports range
        #    ports:
        #      from: 80
        #      to: 80
        #    # Additional AWS tags
        #    tags: {}
    # aws-auth configmap definition, see https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html for more information.
    awsAuth: {}
    #  additionalAccounts:
    #    - "777777777777"
    #    - "88888888888"
    #  users:
    #    - username: "johndoe"
    #      groups:
    #        - system:masters
    #      userarn: "arn:aws:iam::123456789012:user/johndoe"
    #  roles:
    #    - username: "example"
    #      groups:
    #        - example:masters
    #      rolearn: "arn:aws:iam::123456789012:role/k8s-example-role"
    # Optional. Use when spec.infrastructure is left empty and the VPC is not managed by furyctl
    # vpcId: "vpc-123456780"
  # This section describes how the KFD distribution will be installed
  distribution:
    # This common configuration will be applied to all the packages that will be installed in the cluster
    common:
      # The node selector to use to place the pods for all the KFD packages
      nodeSelector:
        node.kubernetes.io/role: infra
      # The tolerations that will be added to the pods for all the KFD packages
      tolerations:
        - effect: NoSchedule
          key: node.kubernetes.io/role
          value: infra
    # This section contains all the configurations for all the KFD core modules
    modules:
      # This section contains all the configurations for the ingress module
      ingress:
        # the base domain used for all the KFD ingresses, if in the nginx dual configuration, it should be the same as the .spec.distribution.modules.ingress.dns.private.name zone
        baseDomain: internal.example.dev
        # configurations for the nginx ingress controller package
        nginx:
          # type defines if the nginx should be configured as single or dual (internal + external) or none, with none no ingress controller will be deployed and also no ingress resource will be created
          type: dual
          # the tls section defines how the tls for the ingresses should be managed
          tls:
            # provider can be certManager, secret
            provider: certManager
            # if provider is set as secret, this key will be used to create the certificate in the cluster
            # secret:
              # the certificate file content or you can use the file notation to get the content from a file
              # cert: "{file://relative/path/to/ssl.crt}"
              # the key file, a file notation can be used to get the content from a file
              # key: "{file://relative/path/to/ssl.key}"
              # the ca file, a file notation can be used to get the content from a file
              # ca: "{file://relative/path/to/ssl.ca}"
        # configuration for the cert-manager package
        certManager:
          # the configuration for the clusterIssuer that will be created
          clusterIssuer:
            # the name of the clusterIssuer
            name: letsencrypt-fury
            # the email used during issuing procedures
            email: example@sighup.io
            # you can configure the clusterIssuer by specifing type (can be http01 or dns01, if dns01 the route53 integration will be used) or custom solvers
            type: http01
            # the custom solvers configurations
            # solvers:
            #   - http01:
            #       ingress:
            #         class: nginx
        # DNS definition, used in conjunction with externalDNS package to automate DNS management and certificates emission.
        dns:
          # the public DNS zone definition
          public:
            # the name of the zone
            name: "example.dev"
            # manage if we need to create the zone, or if it already exists and we only need to adopt/use it
            create: false
          # the private DNS zone definition, that will be attached to the VPC
          private:
            # the name of the zone
            name: "internal.example.dev"
            # defines if we need to create the zone, or if it already exists and we only need to adopt/use it
            create: false
      # This section contains all the configurations for the logging module
      logging:
        # can be opensearch, loki, customOutput or none. With none, the logging module won't be installed
        type: loki
        # configurations for the loki package
        loki:
          tsdbStartDate: "2024-11-20"
        # configurations for the minio-ha package
        minio:
          # the PVC size for each minio disk, 6 disks total
          storageSize: "20Gi"
      # This section contains all the configurations for the monitoring module
      monitoring:
        # can be prometheus, prometheusAgent, mimir or none. With none, nothing from the monitoring module will be installed
        type: "prometheus"
      # This section contains all the configurations for the tracing module
      tracing:
        # can be tempo or none, with none, nothing from the tracing module will be installed
        type: tempo
        # configurations for the minio-ha package
        minio:
          # the PVC size for each minio disk, 6 disks total
          storageSize: "20Gi"
      # This section contains all the configurations for the policy (opa) module
      policy:
        # type can be gatekeeper, kyverno or none
        type: gatekeeper
        # configurations for the gatekeeper package
        gatekeeper:
          # This parameter adds namespaces to Gatekeeper's exemption list, so it will not enforce the constraints on them.
          additionalExcludedNamespaces: []
          installDefaultPolicies: true
          enforcementAction: deny
      # This section contains all the configurations for the Disaster Recovery module
      dr:
        # can be none or eks
        type: eks
        # Configurations for the velero package
        velero:
          # Velero configurations for EKS cluster
          eks:
            # The S3 bucket that will be created to store the backups
            bucketName: example-velero
            # The region where the bucket will be created (can be different from the overall region defined in .spec.region)
            region: eu-west-1
      # This section contains all the configurations for the auth module
      auth:
        provider:
          # The authentication type used for the infrastructure ingresses (all the ingress for the distribution) can be none, basicAuth, sso
          type: none
        # The base domain used for all the auth ingresses, if in the nginx dual configuration, it should be the same as the .spec.distribution.modules.ingress.dns.public.name zone
        baseDomain: example.dev
    # Custom Patches to add or override fields in the generated manifests
    #customPatches: {}
  # Plugins to be installed
  #plugins: {}
