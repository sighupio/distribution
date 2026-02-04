# SIGHUP Distribution Release TBD

Welcome to SD release TBD

The distribution is maintained with ❤️ by the team [SIGHUP by ReeVo](https://sighup.io/).

## New features 🌟

- [[#483](https://github.com/sighupio/distribution/pull/483)] Added support for HAProxy ingress controller and BYOIC (Bring Your Own Ingress Controller) mode. HAProxy is adopted as the new reference ingress controller following the official NGINX retirement announcement. When both NGINX and HAProxy are enabled, HAProxy takes priority for infrastructure ingresses, while the cluster-wide default IngressClass remains `nginx`. BYOIC mode allows using a custom ingress controller deployed as a distribution plugin, not managed by the SD lifecycle.
- [[#468](https://github.com/sighupio/distribution/pull/468)] Replaced Terraform with OpenTofu: furyctl now uses the OpenTofu v1.10.0 binary instead of Terraform. A new `spec.toolsConfiguration.opentofu` field is available for state backend configuration. The `spec.toolsConfiguration.terraform` field is deprecated and will be removed in a future version. To use the new field, add the `opentofu` key to your furyctl.yaml file with the same S3 backend:

  ```yaml
  spec:
    toolsConfiguration:
      opentofu:     # Before was terraform
        state:
          s3:
            bucketName: your-bucket-name       # Same as terraform
            keyPrefix: your-key-prefix          # Same as terraform
            region: your-region                 # Same as terraform
  ```

- [[#479](https://github.com/sighupio/distribution/pull/479)] Add `vpn_furyagent_path` to infrastructure terraform template for EKSCluster provider to avoid re-download.
- [[#482](https://github.com/sighupio/distribution/pull/482)] Added `kubeadmDownloadUrl`, `kubeadmChecksum`, and `kubeadmBinaryDir` fields to `spec.kubernetes.advanced.airGap` for air-gapped on-premises clusters, used on dedicated etcd nodes for certificate management.
- [[#459](https://github.com/sighupio/distribution/pull/459)] Support for kube-proxy-less clusters: on-premises clusters can be now created without kube-proxy. Disabling kube-proxy will enable Calico in eBPF mode and Cilium's kube-proxy-replacement mode in the networking module. You can disable the kube-proxy like so:

  ```yaml
  apiVersion: kfd.sighup.io/v1alpha2
  kind: OnPremises
  metadata:
    name: kube-proxy-less
  spec:
    kubernetes:
      advanced:
        kubeProxy:
          enabled: false
      ...
  ```

- [[#442](https://github.com/sighupio/distribution/pull/442)] Added GCS (Google Cloud Storage) as a supported backend for the DR module configuration and added support for new fields. 

## Bug Fixes 🐛

- [[#480]](https://github.com/sighupio/distribution/pull/480) The `x509-certificate-exporter-data-plane` DaemonSet was incorrectly patched with the common nodeSelector (e.g., infra nodes), so was unable to monitor kubelet certificates on all worker nodes.

- [[#477]](https://github.com/sighupio/distribution/pull/477) Both control-plane Pods and Etcd systemd service make use of several kubeadm-generated PKI files. These files are generated using a dedicated CA PKI that is expected to be already available in the target node. This PR makes sure that these CA PKI are uploaded to targets nodes in a way that prevents any inconsistencies on file permissions and ownership, which could case errors during etcd or control-plane Pods startup.


## Breaking Changes 💔

### Pomerium policy key renaming

The Pomerium default route policy key for Forecastle has been renamed from `ingressNgnixForecastle` to `ingressForecastle` to reflect that Forecastle is no longer tied to NGINX (now supports also HAProxy and BYOIC mode).

Before:
```yaml
spec:
  distribution:
    modules:
      auth:
        pomerium:
          defaultRoutesPolicy:
            ingressNgnixForecastle:  # Old key
              - allow:
```

After:
```yaml
spec:
  distribution:
    modules:
      auth:
        pomerium:
          defaultRoutesPolicy:
            ingressForecastle:  # New key
              - allow:
```

### Terraform key deprecation

The `spec.toolsConfiguration.terraform` field is deprecated in favor of `spec.toolsConfiguration.opentofu`. Users are encouraged to migrate to `opentofu` configuration, as the the `terraform` field will be removed in a future version.

## Upgrade procedure

Check the [upgrade docs](https://docs.sighup.io/docs/installation/upgrades/) for the steps to upgrade the SIGHUP Distribution from one version to the next using furyctl.
