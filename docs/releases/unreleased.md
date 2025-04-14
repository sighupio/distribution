# SIGHUP Distribution Release vx.xx.x

Welcome to SD release `vx.xx.x`.

The distribution is maintained with ❤️ by the team [SIGHUP by ReeVo](https://sighup.io/).

## New Features since `vx.xx.x`

### Installer Updates

### Module updates

## Breaking changes 💔

## New features 🌟

## Fixes 🐞
- [[#387](https://github.com/sighupio/distribution/pull/387)]: fixed an issue that prevented the control planes nodes array to be marked as immutable under the OnPremises provider. The number of control plane nodes was set as immutable in the 1.31.1 release cycle because we don't have any support to scale the etcd cluster with the number of control plane nodes yet. Moreover, the etcd cluster can be placed either on control plane nodes or set-up on separate machines, adding further cases to the etcd scaling support, which at the moment we don't have.

### Security fixes

## Upgrade procedure

Check the [upgrade docs](https://docs.kubernetesfury.com/docs/installation/upgrades) for the detailed procedure.
