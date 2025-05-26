# SIGHUP Distribution Release vTBD

Welcome to SD release `vTBD`.

The distribution is maintained with ❤️ by the team [SIGHUP by ReeVo](https://sighup.io/).

## New Features since `v1.32.0`

This version adds customizations to make it easier to install SD on bare metal nodes.

## Breaking changes 💔

## New features 🌟

- [[#415](https://github.com/sighupio/distribution/pull/415)]: Adds customizations to make it easier to install SD on bare metal nodes:
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

### Security fixes

## Upgrade procedure

Check the [upgrade docs](https://docs.sighup.io/docs/installation/upgrades/) for the detailed procedure.
