# SIGHUP Distribution Release vTBD

Welcome to the latest release of SD maintained by SIGHUP by ReeVo team.

## New features 🌟

TBD

## Bug fixes 🐞

- [[#581](https://github.com/sighupio/distribution/issues/581)] Immutable: node `storage.installDisk` now accepts persistent device paths like `/dev/disk/by-id/wwn-...`, `/dev/disk/by-path/...` and `/dev/mapper/...`. The field is validated the same way Butane/Ignition validates its own device fields — the path must be absolute and clean — instead of the previous alphanumeric-only pattern that rejected every `/dev/disk/by-*` symlink.

## Breaking Changes 💔

TBD
