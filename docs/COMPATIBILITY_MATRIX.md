# Compatibility Matrix

## Maintained releases

Next is a table with the KFD releases that are under active maintenance and their compatibility with current Kubernetes versions.

For a complete list of all KFD releases and their compatibility with Kubernetes versions please see the [unmaintained releases section](#unmaintained-releases-%EF%B8%8F) below.

ℹ️ **Use the latest patch release for your desired version whenever it's possible**. See [the versioning file](VERSIONING.md) for more information.

| KFD / Kubernetes Version                                                      |       1.25.X       |       1.24.X       |       1.23.X       |
| ----------------------------------------------------------------------------- | :----------------: | :----------------: | :----------------: |
| [v1.25.6](https://github.com/sighupio/fury-distribution/releases/tag/v1.25.7) | :white_check_mark: |                    |                    |
| [v1.25.6](https://github.com/sighupio/fury-distribution/releases/tag/v1.25.6) | :white_check_mark: |                    |                    |
| [v1.25.5](https://github.com/sighupio/fury-distribution/releases/tag/v1.25.5) | :white_check_mark: |                    |                    |
| [v1.25.4](https://github.com/sighupio/fury-distribution/releases/tag/v1.25.4) | :white_check_mark: |                    |                    |
| [v1.25.3](https://github.com/sighupio/fury-distribution/releases/tag/v1.25.3) | :white_check_mark: |                    |                    |
| [v1.25.2](https://github.com/sighupio/fury-distribution/releases/tag/v1.25.2) | :white_check_mark: |                    |                    |
| [v1.25.1](https://github.com/sighupio/fury-distribution/releases/tag/v1.25.1) | :white_check_mark: |                    |                    |
| [v1.25.0](https://github.com/sighupio/fury-distribution/releases/tag/v1.25.0) | :white_check_mark: |                    |                    |
| [v1.24.1](https://github.com/sighupio/fury-distribution/releases/tag/v1.24.1) |                    | :white_check_mark: |                    |
| [v1.24.0](https://github.com/sighupio/fury-distribution/releases/tag/v1.24.0) |                    | :white_check_mark: |                    |
| [v1.23.4](https://github.com/sighupio/fury-distribution/releases/tag/v1.23.4) |                    |                    | :white_check_mark: |
| [v1.23.3](https://github.com/sighupio/fury-distribution/releases/tag/v1.23.3) |                    |                    | :white_check_mark: |
| [v1.23.2](https://github.com/sighupio/fury-distribution/releases/tag/v1.23.2) |                    |                    | :white_check_mark: |
| [v1.23.1](https://github.com/sighupio/fury-distribution/releases/tag/v1.23.1) |                    |                    |     :warning:      |
| [v1.23.0](https://github.com/sighupio/fury-distribution/releases/tag/v1.23.0) |                    |                    |        :x:         |

|       Legend       | Meaning          |
| :----------------: | ---------------- |
| :white_check_mark: | Compatible       |
|     :warning:      | Has known issues |
|        :x:         | Incompatible     |

### Furyctl and KFD compatibility

| Furyctl / KFD  | 1.25.7             | 1.25.6             | 1.25.5             | 1.25.4             | 1.25.3             | 1.25.2             |
| -------------- | ------------------ | ------------------ | ------------------ | ------------------ | ------------------ | ------------------ |
| 0.25.2         | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |
| 0.25.1         | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |
| 0.25.0         | :white_check_mark: | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |
| 0.25.0-beta.0  |                    |                    |                    |                    | :white_check_mark: |                    |
| 0.25.0-alpha.1 |                    |                    |                    |                    |                    | :white_check_mark: |

See [Furyctl](https://github.com/sighupio/furyctl) repository for more informations on it's usage.

> We suggest to always use the latest furyctl and KFD versions available

### Warnings

- :x: version `v1.23.0` has a known bug that breaks upgrades. Do not use.

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
