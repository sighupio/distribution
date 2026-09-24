# SIGHUP Distribution Release vTBD

Welcome to the latest release of SD maintained by SIGHUP by ReeVo team.

## New features 🌟

- [[#575](https://github.com/sighupio/furyctl/issues/575)] OnPremises and Immutable: add support for the new [`furyctl renew kubeconfigs`](https://github.com/sighupio/distribution/pull/588) command. It renews the kubeconfig file of the admin and the kubeconfig files of the users in `spec.kubernetes.advanced.users.names`. Then it downloads them to the working directory. A user that you add to the configuration file gets a kubeconfig file. It is not necessary to apply the kubernetes phase.

- [[#600](https://github.com/sighupio/distribution/pull/600)] Immutable: `spec.infrastructure.proxy` now applies to the whole node and not only to containerd. kubelet, etcd, the system extension downloads and command line tools like `curl` now use the proxy. Note that proxy configuration does not apply to the operating system installation step.

- [[#601](https://github.com/sighupio/distribution/pull/601)] Immutable: the infrastructure phase now upgrades the load balancers. The new `upgrade-load-balancers.yml` playbook updates the operating system, the system extensions and the configuration. It upgrades one load balancer at a time, so the virtual IP address stays available. The playbook stops before it changes anything when a load balancer does not answer.

## Bug fixes 🐞

- [[#581](https://github.com/sighupio/distribution/issues/581)] Immutable: node `storage.installDisk` now accepts persistent device paths like `/dev/disk/by-id/wwn-...`, `/dev/disk/by-path/...` and `/dev/mapper/...`. The field is validated the same way Butane/Ignition validates its own device fields — the path must be absolute and clean — instead of the previous alphanumeric-only pattern that rejected every `/dev/disk/by-*` symlink.
- [[#603](https://github.com/sighupio/distribution/pull/603)] Immutable: the preflight check now stops when it cannot reach a control plane node. Before this release, a node that did not answer gave the same result as a cluster that does not exist. The apply then continued as if the cluster was new. The check also finds an existing cluster when a control plane node other than the first one holds the admin kubeconfig.
- [[#605](https://github.com/sighupio/distribution/pull/605)] Immutable: the preflight check now reads every host, and not only the control plane hosts. It tells a cluster whose control plane does not answer from a cluster that does not exist, and furyctl stops the apply in the first case.
- [[#577](https://github.com/sighupio/distribution/pull/577)] Makes the admin.conf fetch in fetch-admin-conf-playbook.yaml pick the right master, and stops the playbook from failing on purpose to signal "cluster doesn't exist".
- [[#573](https://github.com/sighupio/distribution/issues/573)] Immutable: you can now apply the configuration file that `furyctl create config` generates without changes to it. Each node must now declare `arch`, and the generated file sets it on all the nodes. The schema declared a default of `x86-64` for `arch`, but nothing applied that default. A node without the field made `furyctl apply` stop with a template error.
- [[#607](https://github.com/sighupio/distribution/pull/607)] DR module: fix velero triggering immediate backups after every `furyctl apply`.

## Breaking Changes 💔

- [[#600](https://github.com/sighupio/distribution/pull/600)] Immutable: `spec.infrastructure.proxy` now applies to every service on the node, so `noProxy` must list the addresses that the cluster uses to reach itself. Add the network of the nodes, the control plane address, the pod CIDR and the service CIDR. If these addresses are absent, kubelet and the other components try to reach the API server through the proxy, and the cluster does not start.
