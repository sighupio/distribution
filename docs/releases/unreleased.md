# SIGHUP Distribution Release vTBD

Welcome to the latest release of SD maintained by SIGHUP by ReeVo team.

## New features 🌟

- [[#575](https://github.com/sighupio/furyctl/issues/575)] OnPremises and Immutable: add support for the new [`furyctl renew kubeconfigs`](https://github.com/sighupio/distribution/pull/588) command. It renews the kubeconfig file of the admin and the kubeconfig files of the users in `spec.kubernetes.advanced.users.names`. Then it downloads them to the working directory. A user that you add to the configuration file gets a kubeconfig file. It is not necessary to apply the kubernetes phase.

## Bug fixes 🐞

- [[#581](https://github.com/sighupio/distribution/issues/581)] Immutable: node `storage.installDisk` now accepts persistent device paths like `/dev/disk/by-id/wwn-...`, `/dev/disk/by-path/...` and `/dev/mapper/...`. The field is validated the same way Butane/Ignition validates its own device fields — the path must be absolute and clean — instead of the previous alphanumeric-only pattern that rejected every `/dev/disk/by-*` symlink.
- [[#577](https://github.com/sighupio/distribution/pull/577)] Makes the admin.conf fetch in verify-playbook.yaml pick the right master, and stops the playbook from failing on purpose to signal "cluster doesn't exist".

## Breaking Changes 💔

TBD
