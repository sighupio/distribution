# SIGHUP Distribution Release vTBD

Welcome to the latest release of SD maintained by SIGHUP by ReeVo team.

## New features 🌟

- [[#553](https://github.com/sighupio/distribution/pull/553)] EKSCluster: added schema validation to require at least one of `privateAccess` or `publicAccess` to be `true` in the Kubernetes API server configuration.
- [[#554](https://github.com/sighupio/distribution/pull/554)] Monitoring: bump PrometheusAgent version to 3.10.0
- [[#TBD](https://github.com/sighupio/distribution/pull/TBD)] Immutable: nodes can now boot on a segment without a DHCP server. furyctl derives an initramfs `ip=`/`nameserver=` kernel argument from a node's static interfaces, and a new optional node `kernelArguments` field (`shouldExist`/`shouldNotExist`, mirroring Butane's `kernel_arguments`) lets you set kernel arguments explicitly.

## Bug fixes 🐞

- [[#555](https://github.com/sighupio/distribution/pull/555)] Monitoring templates: don't try to patch the alertmanagerConfigs when they are not being deployed at all.
- [[#561](https://github.com/sighupio/distribution/pull/561)] Immutable: align possible properties for Kubernetes phase `kubeletConfiguration` parameter with OnPremises, accepting all possible values now.
- [[#564](https://github.com/sighupio/distribution/pull/564)] OnPremises: fixed a race in the preflight `verify-playbook.yaml` where fetching `admin.conf` from multiple masters in parallel could randomly fail with a checksum mismatch.

## Breaking Changes 💔

- [[#559](https://github.com/sighupio/distribution/pull/559)] Immutable: kube-proxy configuration in Kubernetes advanced configuration is now a `type` enum instead of an `enabled` boolean option, following OnPremises' schema. Disabling kube-proxy was actually not working for Immutable due to this inconsistency.
