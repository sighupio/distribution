# SIGHUP Distribution Release vTBD

Welcome to SD release `vTBD`.

The distribution is maintained with ❤️ by the team [SIGHUP by ReeVo](https://sighup.io/).

## New Features since `v1.32.0`

This version adds customizations to make it easier to install SD on bare metal nodes.

## Breaking changes 💔
- [[#445](https://github.com/sighupio/distribution/pull/445)] Amazon Linux 2 AMI deprecation
  - For Kubernetes versions 1.33 and later, EKS will not provide pre-built optimized Amazon Linux 2 (AL2) Amazon Machine Images (AMIs). Users must migrate to Amazon Linux 2023 (alinux2023).
  ```yaml
  spec:
    kubernetes:
      # The only valid value is `alinux2023`. All other values (including `alinux2`) result in a schema validation error.
      nodePoolGlobalAmiType: "alinux2023"
  ```
## New features 🌟

- [[#415](https://github.com/sighupio/distribution/pull/415)] Adds customizations to make it easier to install SD on bare metal nodes:
  - `blockSize` and `podCidr` to the `spec.distribution.modules.networking.tigeraOperator` section of the OnPremises and KFDDistribution schemas, allowing customizations to the assigned CIDR for each node.
  How to use it:

    ```yaml
    spec:
      distribution:
        modules:
          networking:
            type: calico
            tigeraOperator:
              blockSize: 26
              podCidr: 172.16.0.0/16
    ```

  - `kernelParameters` to the `.spec.kubernetes.advanced`, `.spec.kubernetes.masters` and `.spec.kubernetes.nodes[]` sections, to allow customization of kernel parameters of each Kubernetes node. Example:

    ```yaml
    spec:
      kubernetes:
        masters:
          kernelParameters:
          - name: "fs.file-max"
            value: "9223372036854775804"
    ```

- [[#425](https://github.com/sighupio/distribution/pull/425)] Adds trusted CA certificate support in OIDC authentication with self-signed certificates:
  - `oidcTrustedCA` key under `spec.distribution.modules.auth` allows automatic provisioning of custom CA certificates for auth components.
  - Adds secret generation and volume mounting for Gangplank, Pomerium, and Dex deployments.
  - Supports `{file://path}` notation.

    ```yaml
    spec:
      distribution:
        modules:
          auth:
            oidcTrustedCA: "{file://my-ca.crt}"
    ```

- [[#428](https://github.com/sighupio/distribution/issues/428)] Configuration for Logging Operator's Fluentd and Fluentbit resources:
  - Added new configuration options to the logging module that allows to set Fluentd's resources and replicas number and Fluentbit's resources. Example:
  
  ```yaml
  spec:
    distribution:
      modules:
        logging:
          operator:
            fluentd:
              replicas: 1
                resources:
                  limits:
                    cpu: "2500m"
            fluentbit:
              resources:
                requests:
                  memory: "1Mi"
  ```

- [[#429](https://github.com/sighupio/distribution/issues/429)] Control Plane taints for OnPremises clusters:
  - Added new configuration option to set the control plane nodes taints at cluster creation time. Example:
  
  ```yaml
  # custom taint. NOTE: the default taint won't be added, just the ones defined.
  spec:
    kubernetes:
      masters:
        taints:
          - effect: NoExecute
            key: soft-cell
            value: tainted-love
  ```
  
  ```yaml
  # no taints
  spec:
    kubernetes:
      masters:
        taints: []
  ```

- [[#435](https://github.com/sighupio/distribution/pull/435)] Repository management lifecycle configuration for OnPremises provider:
  - Added new boolean configuration fields for environments where package repositories are configured outside of furyctl.
    - `spec.kubernetes.loadBalancers.manageRepositories`: Controls HAProxy repository setup
    - `spec.kubernetes.advanced.containerd.manageRepositories`: Controls NVIDIA container toolkit's repository setup
    - `spec.kubernetes.advanced.manageRepositories`: Controls Kubernetes package repository setup
  - All fields are optional. If omitted, the system defaults to automatic repository management.

    ```yaml
    spec:
      kubernetes:
        loadBalancers:
          enabled: true
          manageRepositories: false
        advanced:
          manageRepositories: false
          containerd:
            manageRepositories: false
    ```

- [[#353](https://github.com/sighupio/fury-distribution/pull/353)] **Add EKS self-managed node pool default override options for IDMS**: add a variable to override the default properies for EKS self-managed node pools. Currently support only the IDMS ones.

## Fixes 🐞

- [installer-eks/issues#88](https://github.com/sighupio/installer-eks/issues/88) This PR fixes an issue when using `selfmanaged` nodes with `alinux2023`. The way we used to provision images relied on Amazon's `bootstrap.sh` which has been deprecated in favor of `nodeadm`.

- Plugins names are now pattern-validated in the schema to avoid potential errors at runtime when setting invalid names.

### Security fixes

## Upgrade procedure

Check the [upgrade docs](https://docs.sighup.io/docs/installation/upgrades/) for the detailed procedure.
