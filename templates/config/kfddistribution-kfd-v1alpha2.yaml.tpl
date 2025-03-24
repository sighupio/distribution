# yaml-language-server: $schema=https://raw.githubusercontent.com/sighupio/fury-distribution/{{.DistributionVersion}}/schemas/public/kfddistribution-kfd-v1alpha2.json
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.


# This is a sample configuration file to be used as a starting point. For the
# complete reference of the configuration file schema, please refer to the
# official documentation:
# https://docs.kubernetesfury.com/docs/installation/kfd-configuration/providers/KFDDistribution

---
apiVersion: kfd.sighup.io/v1alpha2
kind: KFDDistribution
metadata:
  # The name of the cluster, will be also used as a prefix for all the other resources created
  name: {{.Name}}
spec:
  # This value defines which KFD version will be installed and in consequence the Kubernetes version to use to create the cluster,
  # it supports git tags and branches
  distributionVersion: {{.DistributionVersion}}
  # This section describes how the KFD distribution will be installed
  distribution:
    # This common configuration will be applied to all the packages that will be installed in the cluster
    kubeconfig: path/to/kubeconfig
    # common:
    #   # The node selector to use to place the pods for all the KFD packages
    #   nodeSelector:
    #     node.kubernetes.io/role: infra
    #   # The tolerations that will be added to the pods for all the KFD packages
    #   tolerations:
    #     - effect: NoSchedule
    #       key: node.kubernetes.io/role
    #       value: infra
    # This section contains all the configurations for all the KFD core modules
    modules:
      networking:
        # this type defines if we need to install the networking in the cluster, type available: none, cilium, calico
        type: none
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
            # you can configure the clusterIssuer by specifing type (can be only http01) or custom solvers
            type: http01
            # the custom solvers configurations
            # solvers:
            #   - http01:
            #       ingress:
            #         class: nginx
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
        # type can be none or on-premises
        type: on-premises
        # Configurations for the velero package
        velero: {}
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
