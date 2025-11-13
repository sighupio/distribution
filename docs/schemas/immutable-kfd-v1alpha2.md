# Immutable - SD Immutable Cluster Schema

This document explains the full schema for the `kind: Immutable` for the `furyctl.yaml` file used by `furyctl`. This configuration file will be used to deploy the SIGHUP Distribution on Flatcar Container Linux using Matchbox-based provisioning.

An example configuration file can be created by running the following command:

```bash
furyctl create config --kind Immutable --version v1.33.1 --name example-cluster
```

> [!NOTE]
> Replace the version with your desired version of KFD.
## Properties

| Property                  | Type     | Required |
|:--------------------------|:---------|:---------|
| [apiVersion](#apiversion) | `string` | Required |
| [kind](#kind)             | `string` | Required |
| [metadata](#metadata)     | `object` | Required |
| [spec](#spec)             | `object` | Required |

### Description

A KFD Cluster deployed on Flatcar Container Linux using the Immutable provider with Matchbox-based provisioning.

## .apiVersion

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^kfd\.sighup\.io/v\d+((alpha|beta)\d+)?$
```

[try pattern](https://regexr.com/?expression=^kfd\.sighup\.io\/v\d%2B\(\(alpha|beta\)\d%2B\)?$)

## .kind

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value       |
|:------------|
|`"Immutable"`|

## .metadata

### Properties

| Property              | Type     | Required |
|:----------------------|:---------|:---------|
| [name](#metadataname) | `string` | Required |

## .metadata.name

### Description

The name of the cluster. It will also be used as a prefix for all the other resources created.

### Constraints

**maximum length**: the maximum number of characters for this string is: `56`

**minimum length**: the minimum number of characters for this string is: `1`

## .spec

### Properties

| Property                                        | Type     | Required |
|:------------------------------------------------|:---------|:---------|
| [distribution](#specdistribution)               | `object` | Optional |
| [distributionVersion](#specdistributionversion) | `string` | Required |
| [infrastructure](#specinfrastructure)           | `object` | Required |
| [kubernetes](#speckubernetes)                   | `object` | Required |
| [plugins](#specplugins)                         | `object` | Optional |

## .spec.distribution

### Properties

| Property                            | Type     | Required |
|:------------------------------------|:---------|:---------|
| [common](#specdistributioncommon)   | `object` | Optional |
| [modules](#specdistributionmodules) | `object` | Optional |

### Description

SIGHUP Distribution modules configuration. This section is compatible with the existing Distribution schema and follows the same structure as other providers.

## .spec.distribution.common

### Properties

| Property                                    | Type     | Required |
|:--------------------------------------------|:---------|:---------|
| [registry](#specdistributioncommonregistry) | `string` | Optional |

## .spec.distribution.common.registry

### Description

Container registry for Distribution modules. Example: registry.sighup.io/fury

## .spec.distribution.modules

### Description

Distribution modules (networking, ingress, logging, monitoring, dr, policy, etc.). Follows the standard SIGHUP Distribution modules schema.

## .spec.distributionVersion

### Description

Defines which KFD version will be installed and, in consequence, the Kubernetes version used to create the cluster. It supports git tags and branches. Example: `v1.33.1`.

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.infrastructure

### Properties

| Property                                  | Type     | Required |
|:------------------------------------------|:---------|:---------|
| [matchbox](#specinfrastructurematchbox)   | `object` | Required |
| [nodes](#specinfrastructurenodes)         | `object` | Required |
| [osUpdates](#specinfrastructureosupdates) | `object` | Optional |
| [pki](#specinfrastructurepki)             | `object` | Optional |
| [ssh](#specinfrastructuressh)             | `object` | Required |

### Description

Defines the infrastructure layer configuration for the Immutable provider. This section defines infrastructure concerns (Matchbox, OS updates, PKI, SSH access, node inventory) separate from Kubernetes concerns.

## .spec.infrastructure.matchbox

### Properties

| Property                              | Type     | Required |
|:--------------------------------------|:---------|:---------|
| [url](#specinfrastructurematchboxurl) | `string` | Required |

### Description

Matchbox server configuration for PXE/iPXE provisioning.

## .spec.infrastructure.matchbox.url

### Description

Uniform Resource Identifier (URI). Must be a valid URL with scheme. Example: https://example.com:8080

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

**pattern**: the string must match the following regular expression:

```regexp
^https?://[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)*(:[0-9]{1,5})?(/.*)?$
```

[try pattern](https://regexr.com/?expression=^https?:\/\/[a-zA-Z0-9]\([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]\)?\(\.[a-zA-Z0-9]\([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]\)?\)*\(:[0-9]{1,5}\)?\(\/.*\)?$)

## .spec.infrastructure.nodes

### Properties

| Property                                               | Type    | Required |
|:-------------------------------------------------------|:--------|:---------|
| [controlPlanes](#specinfrastructurenodescontrolplanes) | `array` | Required |
| [etcds](#specinfrastructurenodesetcds)                 | `array` | Optional |
| [loadBalancers](#specinfrastructurenodesloadbalancers) | `array` | Optional |
| [workers](#specinfrastructurenodesworkers)             | `array` | Required |

### Description

Node inventory organized by role. Supported roles: controlPlanes (Kubernetes control-plane with stacked etcd by default), workers (Kubernetes worker nodes), loadBalancers (HAProxy load balancers), etcds (optional dedicated etcd nodes, triggers external etcd).

## .spec.infrastructure.nodes.controlPlanes

### Properties

| Property                                                                    | Type     | Required |
|:----------------------------------------------------------------------------|:---------|:---------|
| [hostname](#specinfrastructurenodescontrolplaneshostname)                   | `string` | Required |
| [installDisk](#specinfrastructurenodescontrolplanesinstalldisk)             | `string` | Required |
| [macAddress](#specinfrastructurenodescontrolplanesmacaddress)               | `string` | Required |
| [networkInterfaces](#specinfrastructurenodescontrolplanesnetworkinterfaces) | `array`  | Required |
| [partitioning](#specinfrastructurenodescontrolplanespartitioning)           | `string` | Optional |

### Description

Node definition with network configuration. Applies to all roles: controlPlanes, workers, etcds, loadBalancers.

### Constraints

**minimum number of items**: the minimum number of items for this array is: `1`

## .spec.infrastructure.nodes.controlPlanes.hostname

### Description

Fully Qualified Domain Name (FQDN). Must include domain suffix. Example: server.example.com

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

**pattern**: the string must match the following regular expression:

```regexp
^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$
```

[try pattern](https://regexr.com/?expression=^\([a-zA-Z0-9]\([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]\)?\.\)%2B[a-zA-Z]{2,}$)

## .spec.infrastructure.nodes.controlPlanes.installDisk

### Description

Disk device for Flatcar Container Linux installation. Example: /dev/sda, /dev/nvme0n1

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.infrastructure.nodes.controlPlanes.macAddress

### Description

MAC address in colon-separated hexadecimal format. Example: 52:54:00:12:34:56

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$
```

[try pattern](https://regexr.com/?expression=^\([0-9A-Fa-f]{2}:\){5}[0-9A-Fa-f]{2}$)

## .spec.infrastructure.nodes.controlPlanes.networkInterfaces

### Properties

| Property                                                                     | Type      | Required |
|:-----------------------------------------------------------------------------|:----------|:---------|
| [addresses](#specinfrastructurenodescontrolplanesnetworkinterfacesaddresses) | `array`   | Optional |
| [dhcp](#specinfrastructurenodescontrolplanesnetworkinterfacesdhcp)           | `boolean` | Required |
| [dns](#specinfrastructurenodescontrolplanesnetworkinterfacesdns)             | `array`   | Optional |
| [gateway](#specinfrastructurenodescontrolplanesnetworkinterfacesgateway)     | `string`  | Optional |
| [name](#specinfrastructurenodescontrolplanesnetworkinterfacesname)           | `string`  | Required |

### Description

Network interface configuration for a node.

### Constraints

**minimum number of items**: the minimum number of items for this array is: `1`

## .spec.infrastructure.nodes.controlPlanes.networkInterfaces.addresses

### Description

IPv4 CIDR notation (IP address with subnet mask /0-32). Example: 192.168.1.0/24

### Constraints

**minimum number of items**: the minimum number of items for this array is: `1`

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}/(3[0-2]|[12]?[0-9])$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.?\b\){4}\/\(3[0-2]|[12]?[0-9]\)$)

## .spec.infrastructure.nodes.controlPlanes.networkInterfaces.dhcp

### Description

Use DHCP (true) or static IP configuration (false).

## .spec.infrastructure.nodes.controlPlanes.networkInterfaces.dns

### Description

IPv4 address in dotted decimal notation (0.0.0.0 to 255.255.255.255). Example: 192.168.1.100

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.?\b\){4}$)

## .spec.infrastructure.nodes.controlPlanes.networkInterfaces.gateway

### Description

IPv4 address in dotted decimal notation (0.0.0.0 to 255.255.255.255). Example: 192.168.1.100

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.?\b\){4}$)

## .spec.infrastructure.nodes.controlPlanes.networkInterfaces.name

### Description

Interface name. Examples: eno1, ens3, eth0

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.infrastructure.nodes.controlPlanes.partitioning

### Description

Partitioning strategy. Default: auto

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value  |
|:-------|
|`"auto"`|

## .spec.infrastructure.nodes.etcds

### Properties

| Property                                                            | Type     | Required |
|:--------------------------------------------------------------------|:---------|:---------|
| [hostname](#specinfrastructurenodesetcdshostname)                   | `string` | Required |
| [installDisk](#specinfrastructurenodesetcdsinstalldisk)             | `string` | Required |
| [macAddress](#specinfrastructurenodesetcdsmacaddress)               | `string` | Required |
| [networkInterfaces](#specinfrastructurenodesetcdsnetworkinterfaces) | `array`  | Required |
| [partitioning](#specinfrastructurenodesetcdspartitioning)           | `string` | Optional |

### Description

Node definition with network configuration. Applies to all roles: controlPlanes, workers, etcds, loadBalancers.

### Constraints

**minimum number of items**: the minimum number of items for this array is: `1`

## .spec.infrastructure.nodes.etcds.hostname

### Description

Fully Qualified Domain Name (FQDN). Must include domain suffix. Example: server.example.com

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

**pattern**: the string must match the following regular expression:

```regexp
^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$
```

[try pattern](https://regexr.com/?expression=^\([a-zA-Z0-9]\([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]\)?\.\)%2B[a-zA-Z]{2,}$)

## .spec.infrastructure.nodes.etcds.installDisk

### Description

Disk device for Flatcar Container Linux installation. Example: /dev/sda, /dev/nvme0n1

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.infrastructure.nodes.etcds.macAddress

### Description

MAC address in colon-separated hexadecimal format. Example: 52:54:00:12:34:56

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$
```

[try pattern](https://regexr.com/?expression=^\([0-9A-Fa-f]{2}:\){5}[0-9A-Fa-f]{2}$)

## .spec.infrastructure.nodes.etcds.networkInterfaces

### Properties

| Property                                                             | Type      | Required |
|:---------------------------------------------------------------------|:----------|:---------|
| [addresses](#specinfrastructurenodesetcdsnetworkinterfacesaddresses) | `array`   | Optional |
| [dhcp](#specinfrastructurenodesetcdsnetworkinterfacesdhcp)           | `boolean` | Required |
| [dns](#specinfrastructurenodesetcdsnetworkinterfacesdns)             | `array`   | Optional |
| [gateway](#specinfrastructurenodesetcdsnetworkinterfacesgateway)     | `string`  | Optional |
| [name](#specinfrastructurenodesetcdsnetworkinterfacesname)           | `string`  | Required |

### Description

Network interface configuration for a node.

### Constraints

**minimum number of items**: the minimum number of items for this array is: `1`

## .spec.infrastructure.nodes.etcds.networkInterfaces.addresses

### Description

IPv4 CIDR notation (IP address with subnet mask /0-32). Example: 192.168.1.0/24

### Constraints

**minimum number of items**: the minimum number of items for this array is: `1`

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}/(3[0-2]|[12]?[0-9])$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.?\b\){4}\/\(3[0-2]|[12]?[0-9]\)$)

## .spec.infrastructure.nodes.etcds.networkInterfaces.dhcp

### Description

Use DHCP (true) or static IP configuration (false).

## .spec.infrastructure.nodes.etcds.networkInterfaces.dns

### Description

IPv4 address in dotted decimal notation (0.0.0.0 to 255.255.255.255). Example: 192.168.1.100

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.?\b\){4}$)

## .spec.infrastructure.nodes.etcds.networkInterfaces.gateway

### Description

IPv4 address in dotted decimal notation (0.0.0.0 to 255.255.255.255). Example: 192.168.1.100

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.?\b\){4}$)

## .spec.infrastructure.nodes.etcds.networkInterfaces.name

### Description

Interface name. Examples: eno1, ens3, eth0

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.infrastructure.nodes.etcds.partitioning

### Description

Partitioning strategy. Default: auto

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value  |
|:-------|
|`"auto"`|

## .spec.infrastructure.nodes.loadBalancers

### Properties

| Property                                                                    | Type     | Required |
|:----------------------------------------------------------------------------|:---------|:---------|
| [hostname](#specinfrastructurenodesloadbalancershostname)                   | `string` | Required |
| [installDisk](#specinfrastructurenodesloadbalancersinstalldisk)             | `string` | Required |
| [macAddress](#specinfrastructurenodesloadbalancersmacaddress)               | `string` | Required |
| [networkInterfaces](#specinfrastructurenodesloadbalancersnetworkinterfaces) | `array`  | Required |
| [partitioning](#specinfrastructurenodesloadbalancerspartitioning)           | `string` | Optional |

### Description

Node definition with network configuration. Applies to all roles: controlPlanes, workers, etcds, loadBalancers.

### Constraints

**minimum number of items**: the minimum number of items for this array is: `1`

## .spec.infrastructure.nodes.loadBalancers.hostname

### Description

Fully Qualified Domain Name (FQDN). Must include domain suffix. Example: server.example.com

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

**pattern**: the string must match the following regular expression:

```regexp
^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$
```

[try pattern](https://regexr.com/?expression=^\([a-zA-Z0-9]\([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]\)?\.\)%2B[a-zA-Z]{2,}$)

## .spec.infrastructure.nodes.loadBalancers.installDisk

### Description

Disk device for Flatcar Container Linux installation. Example: /dev/sda, /dev/nvme0n1

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.infrastructure.nodes.loadBalancers.macAddress

### Description

MAC address in colon-separated hexadecimal format. Example: 52:54:00:12:34:56

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$
```

[try pattern](https://regexr.com/?expression=^\([0-9A-Fa-f]{2}:\){5}[0-9A-Fa-f]{2}$)

## .spec.infrastructure.nodes.loadBalancers.networkInterfaces

### Properties

| Property                                                                     | Type      | Required |
|:-----------------------------------------------------------------------------|:----------|:---------|
| [addresses](#specinfrastructurenodesloadbalancersnetworkinterfacesaddresses) | `array`   | Optional |
| [dhcp](#specinfrastructurenodesloadbalancersnetworkinterfacesdhcp)           | `boolean` | Required |
| [dns](#specinfrastructurenodesloadbalancersnetworkinterfacesdns)             | `array`   | Optional |
| [gateway](#specinfrastructurenodesloadbalancersnetworkinterfacesgateway)     | `string`  | Optional |
| [name](#specinfrastructurenodesloadbalancersnetworkinterfacesname)           | `string`  | Required |

### Description

Network interface configuration for a node.

### Constraints

**minimum number of items**: the minimum number of items for this array is: `1`

## .spec.infrastructure.nodes.loadBalancers.networkInterfaces.addresses

### Description

IPv4 CIDR notation (IP address with subnet mask /0-32). Example: 192.168.1.0/24

### Constraints

**minimum number of items**: the minimum number of items for this array is: `1`

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}/(3[0-2]|[12]?[0-9])$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.?\b\){4}\/\(3[0-2]|[12]?[0-9]\)$)

## .spec.infrastructure.nodes.loadBalancers.networkInterfaces.dhcp

### Description

Use DHCP (true) or static IP configuration (false).

## .spec.infrastructure.nodes.loadBalancers.networkInterfaces.dns

### Description

IPv4 address in dotted decimal notation (0.0.0.0 to 255.255.255.255). Example: 192.168.1.100

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.?\b\){4}$)

## .spec.infrastructure.nodes.loadBalancers.networkInterfaces.gateway

### Description

IPv4 address in dotted decimal notation (0.0.0.0 to 255.255.255.255). Example: 192.168.1.100

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.?\b\){4}$)

## .spec.infrastructure.nodes.loadBalancers.networkInterfaces.name

### Description

Interface name. Examples: eno1, ens3, eth0

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.infrastructure.nodes.loadBalancers.partitioning

### Description

Partitioning strategy. Default: auto

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value  |
|:-------|
|`"auto"`|

## .spec.infrastructure.nodes.workers

### Properties

| Property                                                              | Type     | Required |
|:----------------------------------------------------------------------|:---------|:---------|
| [hostname](#specinfrastructurenodesworkershostname)                   | `string` | Required |
| [installDisk](#specinfrastructurenodesworkersinstalldisk)             | `string` | Required |
| [macAddress](#specinfrastructurenodesworkersmacaddress)               | `string` | Required |
| [networkInterfaces](#specinfrastructurenodesworkersnetworkinterfaces) | `array`  | Required |
| [partitioning](#specinfrastructurenodesworkerspartitioning)           | `string` | Optional |

### Description

Node definition with network configuration. Applies to all roles: controlPlanes, workers, etcds, loadBalancers.

### Constraints

**minimum number of items**: the minimum number of items for this array is: `1`

## .spec.infrastructure.nodes.workers.hostname

### Description

Fully Qualified Domain Name (FQDN). Must include domain suffix. Example: server.example.com

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

**pattern**: the string must match the following regular expression:

```regexp
^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$
```

[try pattern](https://regexr.com/?expression=^\([a-zA-Z0-9]\([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]\)?\.\)%2B[a-zA-Z]{2,}$)

## .spec.infrastructure.nodes.workers.installDisk

### Description

Disk device for Flatcar Container Linux installation. Example: /dev/sda, /dev/nvme0n1

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.infrastructure.nodes.workers.macAddress

### Description

MAC address in colon-separated hexadecimal format. Example: 52:54:00:12:34:56

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$
```

[try pattern](https://regexr.com/?expression=^\([0-9A-Fa-f]{2}:\){5}[0-9A-Fa-f]{2}$)

## .spec.infrastructure.nodes.workers.networkInterfaces

### Properties

| Property                                                               | Type      | Required |
|:-----------------------------------------------------------------------|:----------|:---------|
| [addresses](#specinfrastructurenodesworkersnetworkinterfacesaddresses) | `array`   | Optional |
| [dhcp](#specinfrastructurenodesworkersnetworkinterfacesdhcp)           | `boolean` | Required |
| [dns](#specinfrastructurenodesworkersnetworkinterfacesdns)             | `array`   | Optional |
| [gateway](#specinfrastructurenodesworkersnetworkinterfacesgateway)     | `string`  | Optional |
| [name](#specinfrastructurenodesworkersnetworkinterfacesname)           | `string`  | Required |

### Description

Network interface configuration for a node.

### Constraints

**minimum number of items**: the minimum number of items for this array is: `1`

## .spec.infrastructure.nodes.workers.networkInterfaces.addresses

### Description

IPv4 CIDR notation (IP address with subnet mask /0-32). Example: 192.168.1.0/24

### Constraints

**minimum number of items**: the minimum number of items for this array is: `1`

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}/(3[0-2]|[12]?[0-9])$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.?\b\){4}\/\(3[0-2]|[12]?[0-9]\)$)

## .spec.infrastructure.nodes.workers.networkInterfaces.dhcp

### Description

Use DHCP (true) or static IP configuration (false).

## .spec.infrastructure.nodes.workers.networkInterfaces.dns

### Description

IPv4 address in dotted decimal notation (0.0.0.0 to 255.255.255.255). Example: 192.168.1.100

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.?\b\){4}$)

## .spec.infrastructure.nodes.workers.networkInterfaces.gateway

### Description

IPv4 address in dotted decimal notation (0.0.0.0 to 255.255.255.255). Example: 192.168.1.100

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.?\b\){4}$)

## .spec.infrastructure.nodes.workers.networkInterfaces.name

### Description

Interface name. Examples: eno1, ens3, eth0

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.infrastructure.nodes.workers.partitioning

### Description

Partitioning strategy. Default: auto

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value  |
|:-------|
|`"auto"`|

## .spec.infrastructure.osUpdates

### Properties

| Property                                                                         | Type      | Required |
|:---------------------------------------------------------------------------------|:----------|:---------|
| [allowDuringClusterUpdate](#specinfrastructureosupdatesallowduringclusterupdate) | `boolean` | Optional |
| [enabled](#specinfrastructureosupdatesenabled)                                   | `boolean` | Optional |
| [server](#specinfrastructureosupdatesserver)                                     | `string`  | Optional |
| [updateStrategy](#specinfrastructureosupdatesupdatestrategy)                     | `string`  | Optional |

### Description

Controls how Flatcar Container Linux nodes receive OS updates via Nebraska (Omaha protocol).

## .spec.infrastructure.osUpdates.allowDuringClusterUpdate

### Description

Allow OS updates to run during 'furyctl apply' cluster updates. If enabled, OS updates can occur while cluster components are being updated. Default: false

## .spec.infrastructure.osUpdates.enabled

### Description

Enable OS update management. Default: true

## .spec.infrastructure.osUpdates.server

### Description

Nebraska server endpoint for OS updates. If omitted, uses SIGHUP-managed Nebraska server. Provide custom URL for your own Nebraska server (e.g., https://nebraska.internal.example.com). Examples: 'default' (SIGHUP-managed), custom URL

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.infrastructure.osUpdates.updateStrategy

### Description

Update strategy. 'manual': updates require approval. 'automatic': updates apply automatically during cluster maintenance. Default: manual

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value       |
|:------------|
|`"manual"`   |
|`"automatic"`|

## .spec.infrastructure.pki

### Properties

| Property                               | Type     | Required |
|:---------------------------------------|:---------|:---------|
| [folder](#specinfrastructurepkifolder) | `string` | Optional |

### Description

PKI (Public Key Infrastructure) configuration for certificates.

## .spec.infrastructure.pki.folder

### Description

Path to folder containing certificates generated by 'furyctl generate pki'. Default: ./pki

## .spec.infrastructure.ssh

### Properties

| Property                                   | Type      | Required |
|:-------------------------------------------|:----------|:---------|
| [keyPath](#specinfrastructuresshkeypath)   | `string`  | Required |
| [port](#specinfrastructuresshport)         | `integer` | Optional |
| [username](#specinfrastructuresshusername) | `string`  | Optional |

### Description

SSH configuration for accessing cluster nodes.

## .spec.infrastructure.ssh.keyPath

### Description

Path to SSH private key for authentication. Example: ~/.ssh/id_ed25519_cluster

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.infrastructure.ssh.port

### Description

TCP/UDP port number (1-65535)

## .spec.infrastructure.ssh.username

### Description

SSH user with sudo NOPASSWD access. Default: core (Flatcar default user)

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.kubernetes

### Properties

| Property                                                  | Type      | Required |
|:----------------------------------------------------------|:----------|:---------|
| [advanced](#speckubernetesadvanced)                       | `object`  | Optional |
| [controlPlaneAddress](#speckubernetescontrolplaneaddress) | `string`  | Required |
| [controlPlanePort](#speckubernetescontrolplaneport)       | `integer` | Optional |
| [controlPlanes](#speckubernetescontrolplanes)             | `array`   | Required |
| [etcds](#speckubernetesetcds)                             | `array`   | Optional |
| [loadBalancers](#speckubernetesloadbalancers)             | `object`  | Optional |
| [networking](#speckubernetesnetworking)                   | `object`  | Optional |
| [workers](#speckubernetesworkers)                         | `array`   | Required |

### Description

Kubernetes cluster configuration for Ansible. References nodes from spec.infrastructure.nodes with hostname and management IP (must be one of the IPs from networkInterfaces).

## .spec.kubernetes.advanced

### Properties

| Property                                      | Type     | Required |
|:----------------------------------------------|:---------|:---------|
| [apiServer](#speckubernetesadvancedapiserver) | `object` | Optional |
| [registry](#speckubernetesadvancedregistry)   | `string` | Optional |

### Description

Advanced Kubernetes configuration options. Most fields use sensible defaults and only need to be specified if you need to override them.

## .spec.kubernetes.advanced.apiServer

### Properties

| Property                                               | Type     | Required |
|:-------------------------------------------------------|:---------|:---------|
| [extraArgs](#speckubernetesadvancedapiserverextraargs) | `object` | Optional |

### Description

Kubernetes API Server advanced configuration.

## .spec.kubernetes.advanced.apiServer.extraArgs

### Description

Extra arguments to pass to the API server. Key-value pairs. Example: {'audit-log-path': '/var/log/kubernetes/audit.log'}

## .spec.kubernetes.advanced.registry

### Description

Container registry for Kubernetes components. Example: registry.sighup.io/fury

## .spec.kubernetes.controlPlaneAddress

### Description

FQDN or IP address for the Kubernetes API Server endpoint. Points to the load balancer VIP (if using HAProxy) or a single control-plane node. Example: k8s-api.prod.example.com

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.kubernetes.controlPlanePort

### Description

TCP/UDP port number (1-65535)

## .spec.kubernetes.controlPlanes

### Properties

| Property                                         | Type     | Required |
|:-------------------------------------------------|:---------|:---------|
| [hostname](#speckubernetescontrolplaneshostname) | `string` | Required |
| [ip](#speckubernetescontrolplanesip)             | `string` | Required |

### Description

Kubernetes node reference for Ansible configuration. Hostname must match a node from spec.infrastructure.nodes, and IP must be one of the IPs from that node's networkInterfaces.

### Constraints

**minimum number of items**: the minimum number of items for this array is: `1`

## .spec.kubernetes.controlPlanes.hostname

### Description

Fully Qualified Domain Name (FQDN). Must include domain suffix. Example: server.example.com

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

**pattern**: the string must match the following regular expression:

```regexp
^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$
```

[try pattern](https://regexr.com/?expression=^\([a-zA-Z0-9]\([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]\)?\.\)%2B[a-zA-Z]{2,}$)

## .spec.kubernetes.controlPlanes.ip

### Description

IPv4 address in dotted decimal notation (0.0.0.0 to 255.255.255.255). Example: 192.168.1.100

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.?\b\){4}$)

## .spec.kubernetes.etcds

### Properties

| Property                                 | Type     | Required |
|:-----------------------------------------|:---------|:---------|
| [hostname](#speckubernetesetcdshostname) | `string` | Required |
| [ip](#speckubernetesetcdsip)             | `string` | Required |

### Description

Kubernetes node reference for Ansible configuration. Hostname must match a node from spec.infrastructure.nodes, and IP must be one of the IPs from that node's networkInterfaces.

### Constraints

**minimum number of items**: the minimum number of items for this array is: `1`

## .spec.kubernetes.etcds.hostname

### Description

Fully Qualified Domain Name (FQDN). Must include domain suffix. Example: server.example.com

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

**pattern**: the string must match the following regular expression:

```regexp
^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$
```

[try pattern](https://regexr.com/?expression=^\([a-zA-Z0-9]\([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]\)?\.\)%2B[a-zA-Z]{2,}$)

## .spec.kubernetes.etcds.ip

### Description

IPv4 address in dotted decimal notation (0.0.0.0 to 255.255.255.255). Example: 192.168.1.100

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.?\b\){4}$)

## .spec.kubernetes.loadBalancers

### Properties

| Property                                       | Type      | Required |
|:-----------------------------------------------|:----------|:---------|
| [enabled](#speckubernetesloadbalancersenabled) | `boolean` | Optional |
| [hosts](#speckubernetesloadbalancershosts)     | `array`   | Optional |
| [vrrp](#speckubernetesloadbalancersvrrp)       | `object`  | Optional |

### Description

HAProxy load balancers with keepalived for high availability. If disabled, cluster can use external load balancer or direct DNS to a control plane node.

## .spec.kubernetes.loadBalancers.enabled

### Description

Enable HAProxy load balancers. If false, controlPlaneAddress must point to an external load balancer or directly to a control plane node. Default: false

## .spec.kubernetes.loadBalancers.hosts

### Properties

| Property                                              | Type     | Required |
|:------------------------------------------------------|:---------|:---------|
| [hostname](#speckubernetesloadbalancershostshostname) | `string` | Required |
| [ip](#speckubernetesloadbalancershostsip)             | `string` | Required |

### Description

Load balancer host reference for Ansible configuration. Hostname must match a node from spec.infrastructure.nodes.loadBalancers, and IP must be one of the IPs from that node's networkInterfaces.

### Constraints

**minimum number of items**: the minimum number of items for this array is: `1`

## .spec.kubernetes.loadBalancers.hosts.hostname

### Description

Fully Qualified Domain Name (FQDN). Must include domain suffix. Example: server.example.com

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

**pattern**: the string must match the following regular expression:

```regexp
^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$
```

[try pattern](https://regexr.com/?expression=^\([a-zA-Z0-9]\([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]\)?\.\)%2B[a-zA-Z]{2,}$)

## .spec.kubernetes.loadBalancers.hosts.ip

### Description

IPv4 address in dotted decimal notation (0.0.0.0 to 255.255.255.255). Example: 192.168.1.100

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.?\b\){4}$)

## .spec.kubernetes.loadBalancers.vrrp

### Properties

| Property                                                           | Type      | Required |
|:-------------------------------------------------------------------|:----------|:---------|
| [authPassword](#speckubernetesloadbalancersvrrpauthpassword)       | `string`  | Optional |
| [enabled](#speckubernetesloadbalancersvrrpenabled)                 | `boolean` | Optional |
| [interface](#speckubernetesloadbalancersvrrpinterface)             | `string`  | Optional |
| [virtualIP](#speckubernetesloadbalancersvrrpvirtualip)             | `string`  | Optional |
| [virtualRouterID](#speckubernetesloadbalancersvrrpvirtualrouterid) | `integer` | Optional |

### Description

VRRP (Virtual Router Redundancy Protocol) configuration for keepalived. If disabled, load balancers work without high availability (single active LB).

## .spec.kubernetes.loadBalancers.vrrp.authPassword

### Description

Password for VRRP authentication. Required when enabled is true. Prevents rogue VRRP instances. Best practice: use environment variable substitution (e.g., $VRRP_PASSWORD). Maximum length: 8 characters

### Constraints

**maximum length**: the maximum number of characters for this string is: `8`

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.kubernetes.loadBalancers.vrrp.enabled

### Description

Enable VRRP for load balancer high availability. If false, only the first load balancer will be active. Default: false

## .spec.kubernetes.loadBalancers.vrrp.interface

### Description

Network interface where the VIP will be configured. Required when enabled is true. Must exist on ALL load balancer nodes. Examples: ens3, eth0, eno1

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.kubernetes.loadBalancers.vrrp.virtualIP

### Description

IPv4 CIDR notation (IP address with subnet mask /0-32). Example: 192.168.1.0/24

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}/(3[0-2]|[12]?[0-9])$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.?\b\){4}\/\(3[0-2]|[12]?[0-9]\)$)

## .spec.kubernetes.loadBalancers.vrrp.virtualRouterID

### Description

Unique identifier for the VRRP router. Required when enabled is true. Must be unique in the network segment. Range: 1-255

## .spec.kubernetes.networking

### Properties

| Property                                            | Type     | Required |
|:----------------------------------------------------|:---------|:---------|
| [podCIDR](#speckubernetesnetworkingpodcidr)         | `string` | Optional |
| [serviceCIDR](#speckubernetesnetworkingservicecidr) | `string` | Optional |

### Description

Kubernetes network configuration.

## .spec.kubernetes.networking.podCIDR

### Description

IPv4 CIDR notation (IP address with subnet mask /0-32). Example: 192.168.1.0/24

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}/(3[0-2]|[12]?[0-9])$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.?\b\){4}\/\(3[0-2]|[12]?[0-9]\)$)

## .spec.kubernetes.networking.serviceCIDR

### Description

IPv4 CIDR notation (IP address with subnet mask /0-32). Example: 192.168.1.0/24

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}/(3[0-2]|[12]?[0-9])$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.?\b\){4}\/\(3[0-2]|[12]?[0-9]\)$)

## .spec.kubernetes.workers

### Properties

| Property                                   | Type     | Required |
|:-------------------------------------------|:---------|:---------|
| [hostname](#speckubernetesworkershostname) | `string` | Required |
| [ip](#speckubernetesworkersip)             | `string` | Required |

### Description

Kubernetes node reference for Ansible configuration. Hostname must match a node from spec.infrastructure.nodes, and IP must be one of the IPs from that node's networkInterfaces.

### Constraints

**minimum number of items**: the minimum number of items for this array is: `1`

## .spec.kubernetes.workers.hostname

### Description

Fully Qualified Domain Name (FQDN). Must include domain suffix. Example: server.example.com

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

**pattern**: the string must match the following regular expression:

```regexp
^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$
```

[try pattern](https://regexr.com/?expression=^\([a-zA-Z0-9]\([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]\)?\.\)%2B[a-zA-Z]{2,}$)

## .spec.kubernetes.workers.ip

### Description

IPv4 address in dotted decimal notation (0.0.0.0 to 255.255.255.255). Example: 192.168.1.100

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.?\b\){4}$)

## .spec.plugins

### Properties

| Property                           | Type     | Required |
|:-----------------------------------|:---------|:---------|
| [helm](#specpluginshelm)           | `object` | Optional |
| [kustomize](#specpluginskustomize) | `array`  | Optional |

## .spec.plugins.helm

### Properties

| Property                                     | Type    | Required |
|:---------------------------------------------|:--------|:---------|
| [releases](#specpluginshelmreleases)         | `array` | Optional |
| [repositories](#specpluginshelmrepositories) | `array` | Optional |

## .spec.plugins.helm.releases

### Properties

| Property                                                                         | Type      | Required |
|:---------------------------------------------------------------------------------|:----------|:---------|
| [chart](#specpluginshelmreleaseschart)                                           | `string`  | Required |
| [disableValidationOnInstall](#specpluginshelmreleasesdisablevalidationoninstall) | `boolean` | Optional |
| [name](#specpluginshelmreleasesname)                                             | `string`  | Required |
| [namespace](#specpluginshelmreleasesnamespace)                                   | `string`  | Required |
| [set](#specpluginshelmreleasesset)                                               | `array`   | Optional |
| [values](#specpluginshelmreleasesvalues)                                         | `array`   | Optional |
| [version](#specpluginshelmreleasesversion)                                       | `string`  | Optional |

## .spec.plugins.helm.releases.chart

### Description

The chart of the release

## .spec.plugins.helm.releases.disableValidationOnInstall

### Description

Disable running `helm diff` validation when installing the plugin, it will still be done when upgrading.

## .spec.plugins.helm.releases.name

### Description

The name of the release

## .spec.plugins.helm.releases.namespace

### Description

The namespace of the release

## .spec.plugins.helm.releases.set

### Properties

| Property                                  | Type     | Required |
|:------------------------------------------|:---------|:---------|
| [name](#specpluginshelmreleasessetname)   | `string` | Required |
| [value](#specpluginshelmreleasessetvalue) | `string` | Required |

## .spec.plugins.helm.releases.set.name

### Description

The name of the set

## .spec.plugins.helm.releases.set.value

### Description

The value of the set

## .spec.plugins.helm.releases.values

### Description

The values of the release

## .spec.plugins.helm.releases.version

### Description

The version of the release

## .spec.plugins.helm.repositories

### Properties

| Property                                 | Type     | Required |
|:-----------------------------------------|:---------|:---------|
| [name](#specpluginshelmrepositoriesname) | `string` | Required |
| [url](#specpluginshelmrepositoriesurl)   | `string` | Required |

## .spec.plugins.helm.repositories.name

### Description

The name of the repository

## .spec.plugins.helm.repositories.url

### Description

The url of the repository

## .spec.plugins.kustomize

### Properties

| Property                              | Type     | Required |
|:--------------------------------------|:---------|:---------|
| [folder](#specpluginskustomizefolder) | `string` | Required |
| [name](#specpluginskustomizename)     | `string` | Required |

## .spec.plugins.kustomize.folder

### Description

The folder of the kustomize plugin

## .spec.plugins.kustomize.name

### Description

The name of the kustomize plugin. A lowercase RFC 1123 subdomain must consist of lower case alphanumeric characters, '-' or '.', and must start and end with an alphanumeric character (e.g. 'example.com', 'local-storage')

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$
```

[try pattern](https://regexr.com/?expression=^[a-z0-9]\([-a-z0-9]*[a-z0-9]\)?\(\.[a-z0-9]\([-a-z0-9]*[a-z0-9]\)?\)*$)

