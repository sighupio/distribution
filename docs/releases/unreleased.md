# SIGHUP Distribution Release vTBD

Welcome to the latest release of SD maintained by SIGHUP by ReeVo team.

## Breaking changes 💔

- All kinds: removing an entry from `spec.plugins` and running `furyctl apply` left the plugin's resources in the cluster, unmanaged. With furyctl vTBD (the first release after v0.36.1) or later, `furyctl apply` now stops before changing anything when a plugin stored in the cluster configuration is missing from `spec.plugins`, and lists the plugins. To continue, run `furyctl apply --prune-plugins` to delete their resources with the new `templates/plugins/scripts/prune.sh` (kustomize plugins with `kapp delete`, Helm releases with their custom resources, PVCs and CRDs; the release namespace stays), add the entries back, or run `furyctl apply --force plugins-unmanage` to keep the resources outside of furyctl.

## Bug fixes 🐞

- [[#637](https://github.com/sighupio/distribution/pull/637)] When `spec.distribution.common.networkPoliciesEnabled` is `true`, the Headlamp dashboard could not reach Prometheus to show the metrics in the UI because of a missing network policy.
- [[#638](https://github.com/sighupio/distribution/pull/638)] When `spec.distribution.common.networkPoliciesEnabled` is `true`, the Headlamp dashboard could not show logs and events, because no network policy let the Kubernetes API server reach Loki or OpenSearch. The `headlamp` namespace now also has its own network policies, like the other SD namespaces.
- [[#639](https://github.com/sighupio/distribution/pull/639)] When `spec.distribution.common.networkPoliciesEnabled` is `true`, Prometheus could not scrape the Fluentd config-reloader metrics (port 9533) and the Loki gateway metrics (port 4040) because the network policies did not allow these ports.
- [[installer-immutable#40](https://github.com/sighupio/installer-immutable/issues/40)] On the Immutable kind, when an upgrade failed on a node after its reboot and before its uncordon, the next `furyctl apply --upgrade` ended with success and left the node cordoned. The upgrade now runs the uncordon at the end of every node upgrade, drained or not, and then waits for the Ready pods of the node. A node cordoned by hand is uncordoned when the upgrade reaches it, and a control plane on every upgrade run: cordon it again after the upgrade. The wait also runs on a node that was not drained, so the upgrade can now fail on a node that has a pod that is not Ready or is Failed: `--force pods-running-check` skips the wait on workers and control planes.
- [[#642](https://github.com/sighupio/distribution/pull/642)] When `spec.distribution.modules.auth.oidcKubernetesAuth.enabled` is `true` on the OnPremises and Immutable kinds, the validation did not require `auth.dex` and `auth.baseDomain`, so Dex could not start without them. The validation now requires both fields.
