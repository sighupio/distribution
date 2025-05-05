# SIGHUP Distribution Release vx.xx.x

Welcome to SD release `vx.xx.x`.

The distribution is maintained with ❤️ by the team [SIGHUP by ReeVo](https://sighup.io/).

## New Features since `vx.xx.x`

### Installer Updates

### Module updates

## Breaking changes 💔

## New features 🌟
- [[#396](https://github.com/sighupio/distribution/pull/396)]: This PR adds the retention configurations to Loki in logging module. This is an optional field to define retention period for logs stored in Loki. If not set, the default value is 30 days. Users can set it to `0s` to disable retention.
- [[#391](https://github.com/sighupio/distribution/pull/391)]: With this PR users can enable the installation of network policies that will restrict the traffic across all the infrastructural namespaces of SD (SIGHUP Distribution) to just the access needed for its proper functioning and denying the rest of it. This experimental feature is now available also in the KFDDistribution provider.

## Fixes 🐞
- [[#387](https://github.com/sighupio/distribution/pull/387)]: This PR fixed an issue that prevented the control planes nodes array to be treated as immutable under the OnPremises provider. The number of control plane nodes was originally set as immutable in the 1.31.1 release cycle because there isn't any support to scale the etcd cluster with the number of control plane nodes in the SIGHUP Distribution yet. The issue allowed users to change the number of the control plane, even if it was explicitly marked as immutable.
- [[#393](https://github.com/sighupio/distribution/pull/393)]: This PR fixes an issue present when users start the cluster with ingress type none, TLS provider secret, and network policies disabled and try to enable them afterwards.
- [[#401](https://github.com/sighupio/distribution/pull/401)]: Fixed an error in uninstalling the logging module that prevented switching from any logging type to `none` when the monitoring module was not installed.

### Security fixes

## Upgrade procedure

Check the [upgrade docs](https://docs.sighup.io/docs/installation/upgrades/) for the detailed procedure.
