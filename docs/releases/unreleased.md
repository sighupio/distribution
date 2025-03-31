# SIGHUP Distribution Release vTBD

Welcome to SD release `vTBD`.

The distribution is maintained with ❤️ by the team [SIGHUP by ReeVo](https://sighup.io/).

## New Features since `v1.31.0`

### Installer Updates

- TBD

### Module updates

- TBD

## Breaking changes 💔

- [[#358](https://github.com/sighupio/fury-distribution/pull/358)] **Upgrade kustomize to version 5.6.0**: plugins that used old deprecated constructs in their `kustomization.yaml` may not work anymore. Please refer to the release notes of `kustomize` version [4.0.0](https://github.com/kubernetes-sigs/kustomize/releases/tag/kustomize%2Fv4.0.0) and version [5.0.0](https://github.com/kubernetes-sigs/kustomize/releases/tag/kustomize%2Fv5.0.0) for breaking changes that might affect your plugins.

## New features 🌟

- [[#355](https://github.com/sighupio/fury-distribution/pull/355)] **Support for etcd cluster on dedicated nodes**: adding support for deploying etcd on dedicated nodes instead of control plane nodes to the OnPremises provider. For the new clusters, users can define specific hosts for etcd, each with a name and IP. If the etcd key is omitted, etcd will be provisioned on control plane nodes. No migration paths are supported.

To make use of this new feature, you need to define the hosts where etcd will be deployed in your configuration file using the `.spec.kubernetes.etcd` key, for example:



  ```yaml
  ...
  spec:
    kubernetes:
      masters:
        hosts:
          - name: master1
            ip: 192.168.66.29
          - name: master2
            ip: 192.168.66.30
          - name: master3
            ip: 192.168.66.31
      etcd:
        hosts:
          - name: etcd1
            ip: 192.168.66.39
          - name: etcd2
            ip: 192.168.66.40
          - name: etcd3
            ip: 192.168.66.41
      nodes:
        - name: worker
          hosts:
            - name: worker1
              ip: 192.168.66.49
  ...
  ```
- [[#359](https://github.com/sighupio/distribution/pull/359)] **Add etcd backup over S3 and PVC**: we added two new solutions for snapshotting your etcd cluster. It allows a user to save the snapshot in a PersistentVolumeClaim or in a remote S3-bucket.

To make use of this new feature, you need to define how etcdBackup will be deployed in your configuration file, using the `.spec.distribution.dr.etcdBackup` key, for example:

```yaml
spec:
  distribution:
    dr:
      etcdBackup:
        type: "all" # it can be: pvc, s3, all (pvc and s3), none
        backupPrefix: "" # prefix for the filename of the snapshot
        pvc:
          schedule: "0 2 * * *"
          # name: test-pvc (optional name of the pvc: if set it uses an existing one, if left unset it creates one for you)
          size: 1G # size of the created PVC, ignored if name is set
          # accessModes: [] # accessMode used for the created PVC, ignored if name is set
          # storageClass: nome_storage # storage class to use for the created PVC, ignored if name is set
          retentionTime: 10m # how long do you wanna keep your snapshots?
        s3:
          schedule: "0 0 * * *"
          endpoint: play.min.io:9000 # s3 endpoint to upload your snapshots to
          accessKeyId: test
          secretAccessKey: test
          retentionTime: 10m
          bucketName: bucket-name
```
## Fixes 🐞

- [[#334](https://github.com/sighupio/fury-distribution/pull/334)] **Fix to policy module templates**: setting the policy module type to `gatekeeper` and the `additionalExcludedNamespaces` option for Kyverno at the same time resulted in an error do to an bug in the templates logic, this has been fixed.
- [[#336](https://github.com/sighupio/fury-distribution/pull/336)] **Fix race condition when deleting Kyverno**: changing the policy module type from `kyverno` to `none` could, sometimes, end up in a race condition where the API for ClusterPolicy CRD is unregistered before the deletion of the ClusterPolicy objects, resulting in an error in the deletion command execution. The deletion command has been tweaked to avoid this condition.
- [[#344](https://github.com/sighupio/fury-distribution/pull/344)] **Fix Cidr Block additional firewall rule in EKS Cluster**: remove the limitation to have a single CIDR Block additional firewall rule as the EKS installer supports a list.
- [[#348](https://github.com/sighupio/fury-distribution/pull/348)] **Fix `Get previous cluster configuration` failure on first apply**: fixed an issue on `furyctl apply` for on-premises clusters that made it fail with an `ansible-playbook create-playbook.yaml: command failed - exit status 2` error on the very first time it was executed.
- [[#362](https://github.com/sighupio/fury-distribution/pull/348)] **Fix template config files**: fix wrong documentation links inside configuration files created with `furyctl create config`.

## Upgrade procedure

Check the [upgrade docs](https://docs.kubernetesfury.com/docs/installation/upgrades) for the detailed procedure.
