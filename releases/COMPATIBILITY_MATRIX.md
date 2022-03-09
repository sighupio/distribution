# Compatibility Matrix

| Fury Distribution Version / Kubernetes Version | 1.14.X             | 1.15.X             | 1.16.X             | 1.17.X             | 1.18.X             | 1.19.X             | 1.20.X             | 1.21.X             | 1.22.X             | 1.23.X    |
|------------------------------------------------|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|:------------------:|-----------|
| v1.1.0                                         | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                    |                    |           |
| v1.2.0                                         | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |                    |                    |                    |           |
| v1.3.0                                         |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: |                    |                    |                    |                    |           |
| v1.4.0                                         |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: | :warning:          |                    |                    |                    |           |
| v1.5.0                                         |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: | :warning:          |                    |                    |           |
| v1.5.1                                         |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: | :warning:          |                    |                    |           |
| v1.6.0                                         |                    |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: | :warning:          |                    |           |
| v1.7.0                                         |                    |                    |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: | :warning:          |           |
| v1.7.1                                         |                    |                    |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: | :warning:          |           |
| v1.23.0                                        |                    |                    |                    |                    |                    |                    | :x:                | :x:                | :x:                | :warning: |
| v1.23.1                                        |                    |                    |                    |                    |                    |                    | :white_check_mark: | :white_check_mark: | :white_check_mark: | :warning: |

:white_check_mark: Compatible

:warning: Has issues

:x: Incompatible

## Warning

- :x:: version: `v1.23.0` has a known bug breaking upgrades. Please do not use.