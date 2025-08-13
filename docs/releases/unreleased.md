# SIGHUP Distribution Release vTBD

Welcome to SD release `vTBD`.

The distribution is maintained with ❤️ by the team [SIGHUP by ReeVo](https://sighup.io/).

## New Features since `v1.32.0`

This version adds customizations to make it easier to install SD on bare metal nodes.

## Breaking changes 💔

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

  - `kernelParameters` to the `.spec.kubernetes.advanced`, `.spec.kubernetes.masters` and `-spec.kubernetes.nodes[]` sections, to allow customization of kernel parameters of each Kubernetes node. Example:

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

- [[[#428](https://github.com/sighupio/distribution/issues/428)]] Configuration for Logging Operator's Fluentd and Fluentbit resources:
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

## Fixes 🐞

- [installer-eks/issues#88](https://github.com/sighupio/installer-eks/issues/88) This PR fixes an issue when using `selfmanaged` nodes with `alinux2023`. The way we used to provision images relied on Amazon's `bootstrap.sh` which has been deprecated in favor of `nodeadm`.

### Security fixes

## Upgrade procedure

Check the [upgrade docs](https://docs.sighup.io/docs/installation/upgrades/) for the detailed procedure.
