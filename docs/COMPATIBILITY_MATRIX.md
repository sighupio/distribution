# Compatibility Matrix

## Maintained releases

Next is a table with the KFD releases that are under active maintenance and their compatibility with current Kubernetes versions.

For a complete list of all KFD releases and their compatibility with Kubernetes versions please see the [unmaintained releases section](#unmaintained-releases-%EF%B8%8F) below.

ℹ️ **Use the latest patch release for your desired version whenever it's possible**. See [the versioning file](VERSIONING.md) for more information.

| KFD / Kubernetes Version                                                        | v1.28.X            | v1.27.X            | v1.26.X            | 1.25.X             | 1.24.X             |
| ------------------------------------------------------------------------------- | ------------------ | ------------------ | ------------------ | ------------------ | ------------------ |
| [v1.28.1](https://github.com/sighupio/fury-distribution/releases/tag/v1.28.1)   | :white_check_mark: |
| [v1.28.0](https://github.com/sighupio/fury-distribution/releases/tag/v1.28.0)   | :white_check_mark: |                    |                    |                    |                    |
| [v1.27.6](https://github.com/sighupio/fury-distribution/releases/tag/v1.27.6)   |                    | :white_check_mark: |
| [v1.27.5](https://github.com/sighupio/fury-distribution/releases/tag/v1.27.5)   |                    | :white_check_mark: |                    |                    |                    |
| [v1.27.4](https://github.com/sighupio/fury-distribution/releases/tag/v1.27.4)   |                    | :white_check_mark: |                    |                    |                    |
| [v1.27.3](https://github.com/sighupio/fury-distribution/releases/tag/v1.27.3)   |                    | :white_check_mark: |                    |                    |                    |
| [v1.27.2](https://github.com/sighupio/fury-distribution/releases/tag/v1.27.2)   |                    | :white_check_mark: |                    |                    |                    |
| [v1.27.1](https://github.com/sighupio/fury-distribution/releases/tag/v1.27.1)   |                    | :white_check_mark: |                    |                    |                    |
| [v1.27.0](https://github.com/sighupio/fury-distribution/releases/tag/v1.27.0)   |                    | :white_check_mark: |                    |                    |                    |
| [v1.26.6](https://github.com/sighupio/fury-distribution/releases/tag/v1.26.6)   |                    |                    | :white_check_mark: |                    |                    |
| [v1.26.5](https://github.com/sighupio/fury-distribution/releases/tag/v1.26.5)   |                    |                    | :white_check_mark: |                    |                    |
| [v1.26.4](https://github.com/sighupio/fury-distribution/releases/tag/v1.26.4)   |                    |                    | :white_check_mark: |                    |                    |
| [v1.26.3](https://github.com/sighupio/fury-distribution/releases/tag/v1.26.3)   |                    |                    | :white_check_mark: |                    |                    |
| [v1.26.2](https://github.com/sighupio/fury-distribution/releases/tag/v1.26.2)   |                    |                    | :white_check_mark: |                    |                    |
| [v1.26.1](https://github.com/sighupio/fury-distribution/releases/tag/v1.26.1)   |                    |                    | :white_check_mark: |                    |                    |
| [v1.26.0](https://github.com/sighupio/fury-distribution/releases/tag/v1.26.0)   |                    |                    | :white_check_mark: |                    |                    |
| [v1.25.10](https://github.com/sighupio/fury-distribution/releases/tag/v1.25.10) |                    |                    |                    | :white_check_mark: |                    |
| [v1.25.9](https://github.com/sighupio/fury-distribution/releases/tag/v1.25.9)   |                    |                    |                    | :white_check_mark: |                    |
| [v1.25.8](https://github.com/sighupio/fury-distribution/releases/tag/v1.25.8)   |                    |                    |                    | :white_check_mark: |                    |
| [v1.25.7](https://github.com/sighupio/fury-distribution/releases/tag/v1.25.7)   |                    |                    |                    | :white_check_mark: |                    |
| [v1.25.6](https://github.com/sighupio/fury-distribution/releases/tag/v1.25.6)   |                    |                    |                    | :white_check_mark: |                    |
| [v1.25.5](https://github.com/sighupio/fury-distribution/releases/tag/v1.25.5)   |                    |                    |                    | :white_check_mark: |                    |
| [v1.25.4](https://github.com/sighupio/fury-distribution/releases/tag/v1.25.4)   |                    |                    |                    | :white_check_mark: |                    |
| [v1.25.3](https://github.com/sighupio/fury-distribution/releases/tag/v1.25.3)   |                    |                    |                    | :white_check_mark: |                    |
| [v1.25.2](https://github.com/sighupio/fury-distribution/releases/tag/v1.25.2)   |                    |                    |                    | :white_check_mark: |                    |
| [v1.25.1](https://github.com/sighupio/fury-distribution/releases/tag/v1.25.1)   |                    |                    |                    | :white_check_mark: |                    |
| [v1.25.0](https://github.com/sighupio/fury-distribution/releases/tag/v1.25.0)   |                    |                    |                    | :white_check_mark: |                    |
| [v1.24.1](https://github.com/sighupio/fury-distribution/releases/tag/v1.24.1)   |                    |                    |                    |                    | :white_check_mark: |
| [v1.24.0](https://github.com/sighupio/fury-distribution/releases/tag/v1.24.0)   |                    |                    |                    |                    | :white_check_mark: |

|       Legend       | Meaning          |
| :----------------: | ---------------- |
| :white_check_mark: | Compatible       |
|     :warning:      | Has known issues |
|        :x:         | Incompatible     |

### Warnings

- :x: version `v1.23.0` has a known bug that breaks upgrades. Do not use.

### Furyctl and KFD compatibility

Check [Furyctl](https://github.com/sighupio/furyctl) repository for more informations.

## Unmaintained releases 🗄️

In the following table, you can check the compatibility of KFD releases that are not maintained anymore with older Kubernetes versions.

| KFD / Kubernetes Version                                                      |       1.23.X       |       1.22.X       |       1.21.X       |       1.20.X       |       1.19.X       |       1.18.X       |       1.17.X       |       1.16.X       |       1.15.X       |       1.14.X       |
| ----------------------------------------------------------------------------- | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: | :----------------: |
| [v1.22.1](https://github.com/sighupio/fury-distribution/releases/tag/v1.22.1) | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                    |                    |                    |                    |
| [v1.22.0](https://github.com/sighupio/fury-distribution/releases/tag/v1.22.0) |                    | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                    |                    |                    |
| [v1.21.0](https://github.com/sighupio/fury-distribution/releases/tag/v1.21.0) |                    |                    | :white_check_mark: |                    |                    |                    |                    |                    |                    |                    |
| [v1.7.1](https://github.com/sighupio/fury-distribution/releases/tag/v1.7.1)   |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                    |
| [v1.7.0](https://github.com/sighupio/fury-distribution/releases/tag/v1.7.0)   |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                    |
| [v1.6.0](https://github.com/sighupio/fury-distribution/releases/tag/v1.6.0)   |                    |                    |     :warning:      | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |
| [v1.5.1](https://github.com/sighupio/fury-distribution/releases/tag/v1.5.1)   |                    |                    |                    |     :warning:      | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |
| [v1.5.0](https://github.com/sighupio/fury-distribution/releases/tag/v1.5.0)   |                    |                    |                    |     :warning:      |     :warning:      |     :warning:      |     :warning:      |                    |                    |                    |
| [v1.4.0](https://github.com/sighupio/fury-distribution/releases/tag/v1.4.0)   |                    |                    |                    |                    |     :warning:      | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |
| [v1.3.0](https://github.com/sighupio/fury-distribution/releases/tag/v1.3.0)   |                    |                    |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |
| [v1.2.0](https://github.com/sighupio/fury-distribution/releases/tag/v1.2.0)   |                    |                    |                    |                    |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |
| [v1.1.0](https://github.com/sighupio/fury-distribution/releases/tag/v1.1.0)   |                    |                    |                    |                    |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |

|       Legend       | Meaning          |
| :----------------: | ---------------- |
| :white_check_mark: | Compatible       |
|     :warning:      | Has known issues |
|        :x:         | Incompatible     |
