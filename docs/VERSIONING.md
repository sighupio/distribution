# Versioning

SD follows closely Kubernetes versioning.

Starting from the 1.21.0 SD release, the versioning scheme has changed.

We are now versioning SD using the same minor version as the supported Kubernetes version.
This means that each SD version will have a 1:1 compatibility with a specific Kubernetes version.

For example:

- SD 1.22.0 is compatible with Kubernetes 1.22.x
- SD 1.22.5 is compatible with Kubernetes 1.22.x
- SD 1.23.0 is compatible with Kubernetes 1.23.x
- SD 1.23.1 is compatible with Kubernetes 1.23.x
- SD 1.23.2 is compatible with Kubernetes 1.23.x
- SD 1.24.0 is compatible with Kubernetes 1.24.x

## Upgrades

Each SD version will come with comprehensive documentation on all supported upgrade paths (es. tutorials to upgrade minor to minor, including patches if present).

See the [upgrade path](upgrades/UPGRADE_PATH.md) document for more details.
