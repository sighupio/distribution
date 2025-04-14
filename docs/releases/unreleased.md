# SIGHUP Distribution Release vx.xx.x

Welcome to SD release `vx.xx.x`.

The distribution is maintained with ❤️ by the team [SIGHUP by ReeVo](https://sighup.io/).

## New Features since `vx.xx.x`

### Installer Updates

### Module updates

## Breaking changes 💔

## New features 🌟

## Fixes 🐞
- [[#387](https://github.com/sighupio/distribution/pull/387)]: This PR fixed an issue that prevented the control planes nodes array to be treated as immutable under the OnPremises provider. The number of control plane nodes was originally set as immutable in the 1.31.1 release cycle because there isn't any support to scale the etcd cluster with the number of control plane nodes in the SIGHUP Distribution yet. The issue allowed users to change the number of the control plane, even if it was explicitly marked as immutable.

### Security fixes

## Upgrade procedure

Check the [upgrade docs](https://docs.kubernetesfury.com/docs/installation/upgrades) for the detailed procedure.
