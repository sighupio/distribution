# Versioning

SKD follows closely Kubernetes versioning.

Starting from the 1.21.0 SKD release, the versioning scheme has changed.

We are now versioning SKD using the same minor version as the supported Kubernetes version.
This means that each SKD version will have a 1:1 compatibility with a specific Kubernetes version.

For example:

- SKD 1.22.0 is compatible with Kubernetes 1.22.x
- SKD 1.22.5 is compatible with Kubernetes 1.22.x
- SKD 1.23.0 is compatible with Kubernetes 1.23.x
- SKD 1.23.1 is compatible with Kubernetes 1.23.x
- SKD 1.23.2 is compatible with Kubernetes 1.23.x
- SKD 1.24.0 is compatible with Kubernetes 1.24.x

## Upgrades

Each SKD version will come with comprehensive documentation on all supported upgrade paths (es. tutorials to upgrade minor to minor, including patches if present).

See the [upgrade path](upgrades/UPGRADE_PATH.md) document for more details.
