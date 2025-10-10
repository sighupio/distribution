<!-- markdownlint-disable MD033 MD045 -->
<h1 align="center">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/sighupio/distribution/refs/heads/main/docs/assets/white-logo.png">
  <source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/sighupio/distribution/refs/heads/main/docs/assets/black-logo.png">
  <img alt="Shows a black logo in light color mode and a white one in dark color mode." src="https://raw.githubusercontent.com/sighupio/distribution/refs/heads/main/docs/assets/white-logo.png">
</picture><br/>
  SIGHUP Distribution
</h1>

<p align="center">SIGHUP Distribution (SD) is a certified battle-tested Kubernetes distribution based purely on upstream Kubernetes.</p>
<!-- markdownlint-enable MD033 MD045 -->

[![Build Status](http://ci.sighup.io/api/badges/sighupio/distribution/status.svg?ref=refs/tags/v1.31.2)](http://ci.sighup.io/sighupio/distribution)
[![Release](https://img.shields.io/badge/release-v1.31.2-blue?label=DistributionRelease)](https://github.com/sighupio/distribution/releases/latest)
[![Slack](https://img.shields.io/badge/slack-@kubernetes/fury-yellow.svg?logo=slack)](https://kubernetes.slack.com/archives/C0154HYTAQH)
[![License](https://img.shields.io/github/license/sighupio/distribution)](https://github.com/sighupio/distribution/blob/main/LICENSE)

## Overview

SIGHUP Distribution (SD) is a [CNCF certified](https://landscape.cncf.io/?selected=fury-distribution) battle-tested Kubernetes distribution based purely on upstream Kubernetes.

It is developed and maintained by [SIGHUP by ReeVo][sighup-site] and the community, and it is fully open source.

> 🎯 The goal of SD is to turn any standard Kubernetes cluster into a fully-configured production-grade cluster.
<!-- separator -->
> Previously known as KFD (Kubernetes Fury Distribution), the project is now officially named SIGHUP Distribution. ReeVo has acquired SIGHUP, but the project will continue to be open-source and freely available without any changes to its functionality.

## Un-distribution model 🧬

SD uses an **un-distribution model**. This means that we:

- Rely only on open source solutions.
- Are free from vendor lock-in.
- Stay close to upstream Kubernetes and the cloud native landscape.
- Choose, configure and integrate a set of battle-tested open source tools.

## Architecture 🏗

<!-- markdownlint-disable MD033 MD045 -->
<p align="center">
  <img src="docs/assets/skd-architecture.png" width="800px"/>
</p>
<!-- markdownlint-enable MD033 MD045 -->

SIGHUP Distribution is structured on modules, and each module has a set of packages.

- A package is a single unit of functionality.
- A module groups packages that are functionally related together.

> All modules are open source, widely used, easily customizable, and pre-configured with sane defaults and tested to work well together.

The standard way to deploy SD is to:

- Deploy all the [Core Modules](#core-modules-) of the distribution using [furyctl][furyctl].
- Deploy (if needed) any of the [Addon modules](#add-on-modules-) using [furyctl plugin][furyctl-plugins] feature.

See the getting started section below for more information.

### Recommended Hardware Requirements

SD is a modular and composable system, so hardware requirements ultimately depend on the modules and configuration chosen. Having said that, for a production-grade cluster a good starting point would be:

A SD production grade cluster will be composed of 3 node pools:

- Control Plane: 3 nodes in HA.
- Infrastructure: 3 nodes dedicated to running the infrastructural components of SD (monitoring, logging, policy enforcement, etc., i.e. the modules).
- Workers: where the application workload will run. This is up to you.
- Load Balancers (optional): for on-premises installations, 2 load balancers in HA can be deployed to forward traffic to the control plane and the ingress controllers running in the infrastructure nodes.

#### Nodes sizing

| Node Role      | CPU (cores) | RAM (GB) | Disk (GB) | Qty. |
| -------------- | ----------- | -------- | --------- | ---- |
| Control Plane  | 2           | 8        | 50        | 3    |
| Infrastructure | 4           | 16       | 50        | 3    |
| Load Balancer  | 2           | 2        | 50        | 2    |

#### Storage

Some modules rely on persistent storage via PersistentVolumeClaims, by default (but configurable) the following capacity will be used:

| Description                                | Size (GB) |
| ------------------------------------------ | --------: |
| Prometheus (metrics storage)               |       150 |
| MinIO Monitoring (metrics storage, 20GBx6) |       120 |
| MinIO Logging (logs storage, 20GBx6)       |       120 |
| OpenSearch (logs storage)                  |        30 |
| MinIO Tracing (traces storage)             |       120 |
| **Total**                                  |   **540** |

### Core Modules 📦

Core modules provide essential functionality to the distribution for production-grade clusters.

| Module                          | Included Release               | Description                                                                                          |
| ------------------------------- | ------------------------------ | ---------------------------------------------------------------------------------------------------- |
| [Networking][networking-module] | ![Version][networking-version] | Networking functionality via Calico or Cilium CNIs                                                   |
| [Ingress][ingress-module]       | ![Version][ingress-version]    | Fast and reliable Ingress Controller and TLS certificate management                                  |
| [Logging][logging-module]       | ![Version][logging-version]    | A centralized logging solution based on the LoggingOperator + OpenSearch or Loki stacks              |
| [Monitoring][monitoring-module] | ![Version][monitoring-version] | Monitoring and alerting functionality based on Prometheus, AlertManager and Grafana                  |
| [Tracing][tracing-module]       | ![Version][tracing-version]    | Tracing functionality based on Tempo                                                                 |
| [Disaster Recovery][dr-module]  | ![Version][dr-version]         | Backup and disaster recovery solution using Velero                                                   |
| [Policy][policy-module]         | ![Version][policy-version]     | Policy and Governance for your cluster using Gatekeeper and Gatekeeper Policy Manager or Kyverno     |
| [Auth][auth-module]             | ![Version][auth-version]       | Improved auth for your Kubernetes Cluster and its applications                                       |

### Add-on Modules 📦

Add-on modules provide additional functionality to the distribution. Their release cycle is independent of SD's.

| Module                              | Description                                                                  |
| ----------------------------------- | ---------------------------------------------------------------------------- |
| [Kong][kong-module]                 | Add Kong API Gateway for Kubernetes applications via Kong Ingress Controller |
| [Service Mesh][service-mesh-module] | Deploy a service mesh on top of SD                                           |
| [Registry][registry-module]         | Integrate a Container Registry solution                                      |
| [Storage][storage-module]           | Rook (Ceph Operator) based Storage solution on Kubernetes                    |
| [Kafka][kafka-module]               | Apache Kafka event streaming for your Cluster                                |

## Get started with SD 🚀

To get started with SD, please head to the [quickstart guides on the documentation site](https://docs.kubernetesfury.com/docs/distribution/#%EF%B8%8F-how-do-i-get-started).

## Issues 🐛

In case you experience any issues feel free to [open a new issue](https://github.com/sighupio/distribution/issues/new/choose).

If the problem is related to a specific module, open the issue in the module repository.

## Commercial Support 🛟

If you are looking to run SD in production and would like to learn more, SIGHUP (the company behind the Fury ecosystem) can help. Feel free to [email us](mailto:sales@sighup.io) or check out [our website](https://sighup.io).

## Support & Compatibility 🪢

Current supported versions of SD are:

|                                  SD Version                               | Kubernetes Version |
| :-----------------------------------------------------------------------: | :----------------: |
| [`1.33.0`](https://github.com/sighupio/distribution/releases/tag/v1.33.0) |      `1.33.x`      |
| [`1.32.1`](https://github.com/sighupio/distribution/releases/tag/v1.32.1) |      `1.32.x`      |
| [`1.31.2`](https://github.com/sighupio/distribution/releases/tag/v1.31.2) |      `1.31.x`      |

Check the [compatibility matrix][compatibility-matrix] for additional information about previous releases of the Distribution and the compatibility with `furyctl`.

Also, check the [versioning documentation file][versioning] to know more about the versioning scheme of the distribution and the upgrade path.

## CNCF Certified 🎓

Each version of the SIGHUP Distribution that introduces compatibility with a new version of Kubernetes goes through a [conformance certification process with the CNCF][cncf-conformance]. Certified solutions are validated to ensure a set of guarantees such as consistency, timely updates and confirmability.

SD has been certified by the [CNCF] (Cloud Native Computing Foundation) as a _Certified Kubernetes Distribution_ for all Kubernetes versions since [Kubernetes 1.12](https://github.com/cncf/k8s-conformance/pull/619). Clicking on the badge below you can see the certification process for the latest version of SD:

<!-- markdownlint-disable MD033 -->
<p align="center">
    <a href="https://github.com/cncf/k8s-conformance/pull/3528">
        <img src="https://raw.githubusercontent.com/cncf/artwork/main/projects/kubernetes/certified-kubernetes/versionless/pantone/certified-kubernetes-pantone.svg" width="120" alt="SD is CNCF Certified Kubernetes 1.31 - click to see the certification PR"/>
    </a>
</p>
<!-- markdownlint-enable MD033 -->

## Roadmap

Find the updated roadmap in the [ROADMAP.md](ROADMAP.md) file.

## Contributing 🤝

If you wish to contribute please read the [Contributing Guidelines](docs/CONTRIBUTING.md).

## License

SD is open-source software and it's released under the following [LICENSE](LICENSE)

<!-- Core Modules -->

[networking-module]: https://github.com/sighupio/module-networking
[ingress-module]: https://github.com/sighupio/module-ingress
[logging-module]: https://github.com/sighupio/module-logging
[monitoring-module]: https://github.com/sighupio/module-monitoring
[tracing-module]: https://github.com/sighupio/module-tracing
[dr-module]: https://github.com/sighupio/module-dr
[policy-module]: https://github.com/sighupio/module-policy
[auth-module]: https://github.com/sighupio/module-auth
[networking-version]: https://img.shields.io/badge/release-v3.0.0-blue
[ingress-version]: https://img.shields.io/badge/release-v4.1.1-blue
[logging-version]: https://img.shields.io/badge/release-v5.2.0-blue
[monitoring-version]: https://img.shields.io/badge/release-v4.0.1-blue
[tracing-version]: https://img.shields.io/badge/release-v1.3.0-blue
[dr-version]: https://img.shields.io/badge/release-v3.2.0-blue
[policy-version]: https://img.shields.io/badge/release-v1.15.0-blue
[auth-version]: https://img.shields.io/badge/release-v0.6.0-blue

<!-- Addon Modules -->

[kong-module]: https://github.com/sighupio/add-on-kong
[service-mesh-module]: https://github.com/sighupio/add-on-service-mesh
[registry-module]: https://github.com/sighupio/add-on-registry
[storage-module]: https://github.com/sighupio/add-on-storage
[kafka-module]: https://github.com/sighupio/add-on-kafka
[kong-version]: https://img.shields.io/github/v/release/sighupio/add-on-kong
[service-mesh-version]: https://img.shields.io/github/v/release/sighupio/add-on-service-mesh
[registry-version]: https://img.shields.io/github/v/release/sighupio/add-on-registry
[storage-version]: https://img.shields.io/github/v/release/sighupio/add-on-storage
[kafka-version]: https://img.shields.io/github/v/release/sighupio/add-on-kafka
[compatibility-matrix]: https://github.com/sighupio/distribution/blob/main/docs/COMPATIBILITY_MATRIX.md
[versioning]: https://github.com/sighupio/distribution/blob/main/docs/VERSIONING.md

<!-- Misc -->

[furyctl]: https://github.com/sighupio/furyctl
[furyctl-plugins]: https://github.com/sighupio/furyctl?tab=readme-ov-file#plugins
[sighup-site]: https://sighup.io
[CNCF]: https://landscape.cncf.io/?group=certified-partners-and-providers&item=platform--certified-kubernetes-distribution--fury-distribution
[cncf-conformance]: https://www.cncf.io/certification/software-conformance/
