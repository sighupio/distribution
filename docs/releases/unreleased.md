# SIGHUP Distribution Release TBD

Welcome to SD release `vTBD`.

The distribution is maintained with ❤️ by the team [SIGHUP by ReeVo](https://sighup.io/).

## New features 🌟

- [[#505](https://github.com/sighupio/distribution/pull/505)] Support NFTables mode for kube-proxy.
- [[#513](https://github.com/sighupio/distribution/pull/513)] Introduce new `Immutable` kind in alpha status, based on Flatcar Container Linux. This new kind allows to create kubernetes clusters from scracth provisioning fresh (baremetal or virtual) machines with Flatcar Container Linux, gaining immutability and security benefits for your kubernetes clusters.
- [[#519](https://github.com/sighupio/distribution/pull/519)] Allow overriding the `pomerium` auth ingress through `spec.distribution.modules.auth.overrides.ingresses.pomerium`.


## Bug Fixes 🐛

## Breaking changes 💔

- [[#519](https://github.com/sighupio/distribution/pull/519)] For the `EKSCluster` and `KFDDistribution` kinds, `spec.distribution.modules.auth.overrides.ingresses` now only accepts the `gangplank`, `dex` and `pomerium` keys. Previously any key was accepted; configurations using other keys will now fail schema validation.

## Upgrade procedure

Check the [upgrade docs](https://docs.sighup.io/docs/installation/upgrades/) for the steps to upgrade the SIGHUP Distribution from one version to the next using furyctl.
