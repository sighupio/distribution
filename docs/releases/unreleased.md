# SIGHUP Distribution Release vTBD

Welcome to the latest release of SD maintained by SIGHUP by ReeVo team.

## New features 🌟

- [[#644](https://github.com/sighupio/distribution/pull/644)] Immutable: adds what `furyctl delete cluster` ([furyctl#819](https://github.com/sighupio/furyctl/pull/819)) needs to delete the cluster: delete scripts for the plugins and the distribution, and a playbook that erases the partition table of the install disk of every node.
- [[#645](https://github.com/sighupio/distribution/pull/645)] Immutable: the playbooks that `furyctl apply --reinstall-node` and `furyctl delete node` ([furyctl#824](https://github.com/sighupio/furyctl/pull/824)) need. The delete playbook can now drain and erase a single worker or load balancer, and two new `reinstall-node.yaml` playbooks configure the host again and join a worker back to the cluster.

## Breaking changes 💔

- [[#644](https://github.com/sighupio/distribution/pull/644)] OnPremises and KFDDistribution: `furyctl delete cluster` now deletes the distribution like Immutable, with `kapp delete` of what `furyctl apply` installed. It stops when an object cannot be deleted; objects stuck on a finalizer are only reported. On OnPremises the nodes are then not reset: run `--phase kubernetes` after fixing the cause.

## Bug fixes 🐞

- [[#637](https://github.com/sighupio/distribution/pull/637)] When `spec.distribution.common.networkPoliciesEnabled` is `true`, the Headlamp dashboard could not reach Prometheus to show the metrics in the UI because of a missing network policy.
- [[#638](https://github.com/sighupio/distribution/pull/638)] When `spec.distribution.common.networkPoliciesEnabled` is `true`, the Headlamp dashboard could not show logs and events, because no network policy let the Kubernetes API server reach Loki or OpenSearch. The `headlamp` namespace now also has its own network policies, like the other SD namespaces.
- [[#639](https://github.com/sighupio/distribution/pull/639)] When `spec.distribution.common.networkPoliciesEnabled` is `true`, Prometheus could not scrape the Fluentd config-reloader metrics (port 9533) and the Loki gateway metrics (port 4040) because the network policies did not allow these ports.
- [[installer-immutable#40](https://github.com/sighupio/installer-immutable/issues/40)] On the Immutable kind, when an upgrade failed on a node after its reboot and before its uncordon, the next `furyctl apply --upgrade` ended with success and left the node cordoned. The upgrade now runs the uncordon at the end of every node upgrade, drained or not, and then waits for the Ready pods of the node. A node cordoned by hand is uncordoned when the upgrade reaches it, and a control plane on every upgrade run: cordon it again after the upgrade. The wait also runs on a node that was not drained, so the upgrade can now fail on a node that has a pod that is not Ready or is Failed: `--force pods-running-check` skips the wait on workers and control planes.
- [[#642](https://github.com/sighupio/distribution/pull/642)] When `spec.distribution.modules.auth.oidcKubernetesAuth.enabled` is `true` on the OnPremises and Immutable kinds, the validation did not require `auth.dex` and `auth.baseDomain`, so Dex could not start without them. The validation now requires both fields.
