# Immutable - Bare Metal Immutable Infrastructure Schema

This document explains the full schema for the `kind: Immutable` for the `furyctl.yaml` file used by `furyctl`. This configuration file will be used to provision and deploy bare metal nodes with iPXE boot, storage partitioning, network configuration, and the SIGHUP Distribution modules for immutable Kubernetes infrastructure.

An example configuration file can be created by running the following command:

```bash
furyctl create config --kind Immutable --version v1.32.1 --name production-cluster
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

A KFD Cluster deployed on bare metal infrastructure with iPXE boot provisioning and immutable OS configuration.

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
| [distribution](#specdistribution)               | `object` | Required |
| [distributionVersion](#specdistributionversion) | `string` | Required |
| [infrastructure](#specinfrastructure)           | `object` | Required |
| [kubernetes](#speckubernetes)                   | `object` | Required |
| [plugins](#specplugins)                         | `object` | Optional |

## .spec.distribution

### Properties

| Property                                        | Type     | Required |
|:------------------------------------------------|:---------|:---------|
| [common](#specdistributioncommon)               | `object` | Optional |
| [customPatches](#specdistributioncustompatches) | `object` | Optional |
| [modules](#specdistributionmodules)             | `object` | Required |

### Description

Fury Kubernetes Distribution modules configuration. Ref: https://docs.kubernetesfury.com/

## .spec.distribution.common

### Properties

| Property                                            | Type     | Required |
|:----------------------------------------------------|:---------|:---------|
| [nodeSelector](#specdistributioncommonnodeselector) | `object` | Optional |
| [registry](#specdistributioncommonregistry)         | `string` | Optional |
| [tolerations](#specdistributioncommontolerations)   | `array`  | Optional |

### Description

Common configuration for all distribution modules.

## .spec.distribution.common.nodeSelector

### Description

Node selector for all KFD module pods.

## .spec.distribution.common.registry

### Description

Container registry URL for KFD images. Example: registry.sighup.io/fury

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,}(:[0-9]{1,5})?(/[a-z0-9._-]+)*$
```

[try pattern](https://regexr.com/?expression=^\([a-z0-9]\([a-z0-9-]{0,61}[a-z0-9]\)?\.\)%2B[a-z]{2,}\(:[0-9]{1,5}\)?\(\/[a-z0-9._-]%2B\)*$)

## .spec.distribution.common.tolerations

### Properties

| Property                                               | Type     | Required |
|:-------------------------------------------------------|:---------|:---------|
| [effect](#specdistributioncommontolerationseffect)     | `string` | Required |
| [key](#specdistributioncommontolerationskey)           | `string` | Required |
| [operator](#specdistributioncommontolerationsoperator) | `string` | Optional |
| [value](#specdistributioncommontolerationsvalue)       | `string` | Optional |

### Description

Tolerations for all KFD module pods.

## .spec.distribution.common.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.common.tolerations.key

### Description

The key of the toleration

## .spec.distribution.common.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.common.tolerations.value

### Description

The value of the toleration

## .spec.distribution.customPatches

### Properties

| Property                                                                     | Type    | Required |
|:-----------------------------------------------------------------------------|:--------|:---------|
| [configMapGenerator](#specdistributioncustompatchesconfigmapgenerator)       | `array` | Optional |
| [images](#specdistributioncustompatchesimages)                               | `array` | Optional |
| [patches](#specdistributioncustompatchespatches)                             | `array` | Optional |
| [patchesStrategicMerge](#specdistributioncustompatchespatchesstrategicmerge) | `array` | Optional |
| [secretGenerator](#specdistributioncustompatchessecretgenerator)             | `array` | Optional |

## .spec.distribution.customPatches.configMapGenerator

### Properties

| Property                                                               | Type     | Required |
|:-----------------------------------------------------------------------|:---------|:---------|
| [behavior](#specdistributioncustompatchesconfigmapgeneratorbehavior)   | `string` | Optional |
| [envs](#specdistributioncustompatchesconfigmapgeneratorenvs)           | `array`  | Optional |
| [files](#specdistributioncustompatchesconfigmapgeneratorfiles)         | `array`  | Optional |
| [literals](#specdistributioncustompatchesconfigmapgeneratorliterals)   | `array`  | Optional |
| [name](#specdistributioncustompatchesconfigmapgeneratorname)           | `string` | Required |
| [namespace](#specdistributioncustompatchesconfigmapgeneratornamespace) | `string` | Optional |
| [options](#specdistributioncustompatchesconfigmapgeneratoroptions)     | `object` | Optional |

## .spec.distribution.customPatches.configMapGenerator.behavior

### Description

The behavior of the configmap

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value     |
|:----------|
|`"create"` |
|`"replace"`|
|`"merge"`  |

## .spec.distribution.customPatches.configMapGenerator.envs

### Description

The envs of the configmap

## .spec.distribution.customPatches.configMapGenerator.files

### Description

The files of the configmap

## .spec.distribution.customPatches.configMapGenerator.literals

### Description

The literals of the configmap

## .spec.distribution.customPatches.configMapGenerator.name

### Description

The name of the configmap

## .spec.distribution.customPatches.configMapGenerator.namespace

### Description

The namespace of the configmap

## .spec.distribution.customPatches.configMapGenerator.options

### Properties

| Property                                                                                              | Type      | Required |
|:------------------------------------------------------------------------------------------------------|:----------|:---------|
| [annotations](#specdistributioncustompatchesconfigmapgeneratoroptionsannotations)                     | `object`  | Optional |
| [disableNameSuffixHash](#specdistributioncustompatchesconfigmapgeneratoroptionsdisablenamesuffixhash) | `boolean` | Optional |
| [immutable](#specdistributioncustompatchesconfigmapgeneratoroptionsimmutable)                         | `boolean` | Optional |
| [labels](#specdistributioncustompatchesconfigmapgeneratoroptionslabels)                               | `object`  | Optional |

## .spec.distribution.customPatches.configMapGenerator.options.annotations

### Description

The annotations of the configmap

## .spec.distribution.customPatches.configMapGenerator.options.disableNameSuffixHash

### Description

If true, the name suffix hash will be disabled

## .spec.distribution.customPatches.configMapGenerator.options.immutable

### Description

If true, the configmap will be immutable

## .spec.distribution.customPatches.configMapGenerator.options.labels

### Description

The labels of the configmap

## .spec.distribution.customPatches.images

### Description

Each entry should follow the format of Kustomize's images patch

## .spec.distribution.customPatches.patches

### Properties

| Property                                                | Type     | Required |
|:--------------------------------------------------------|:---------|:---------|
| [options](#specdistributioncustompatchespatchesoptions) | `object` | Optional |
| [patch](#specdistributioncustompatchespatchespatch)     | `string` | Optional |
| [path](#specdistributioncustompatchespatchespath)       | `string` | Optional |
| [target](#specdistributioncustompatchespatchestarget)   | `object` | Optional |

## .spec.distribution.customPatches.patches.options

### Properties

| Property                                                                       | Type      | Required |
|:-------------------------------------------------------------------------------|:----------|:---------|
| [allowKindChange](#specdistributioncustompatchespatchesoptionsallowkindchange) | `boolean` | Optional |
| [allowNameChange](#specdistributioncustompatchespatchesoptionsallownamechange) | `boolean` | Optional |

## .spec.distribution.customPatches.patches.options.allowKindChange

### Description

If true, the kind change will be allowed

## .spec.distribution.customPatches.patches.options.allowNameChange

### Description

If true, the name change will be allowed

## .spec.distribution.customPatches.patches.patch

### Description

The patch content

## .spec.distribution.customPatches.patches.path

### Description

The path of the patch

## .spec.distribution.customPatches.patches.target

### Properties

| Property                                                                            | Type     | Required |
|:------------------------------------------------------------------------------------|:---------|:---------|
| [annotationSelector](#specdistributioncustompatchespatchestargetannotationselector) | `string` | Optional |
| [group](#specdistributioncustompatchespatchestargetgroup)                           | `string` | Optional |
| [kind](#specdistributioncustompatchespatchestargetkind)                             | `string` | Optional |
| [labelSelector](#specdistributioncustompatchespatchestargetlabelselector)           | `string` | Optional |
| [name](#specdistributioncustompatchespatchestargetname)                             | `string` | Optional |
| [namespace](#specdistributioncustompatchespatchestargetnamespace)                   | `string` | Optional |
| [version](#specdistributioncustompatchespatchestargetversion)                       | `string` | Optional |

## .spec.distribution.customPatches.patches.target.annotationSelector

### Description

The annotation selector of the target

## .spec.distribution.customPatches.patches.target.group

### Description

The group of the target

## .spec.distribution.customPatches.patches.target.kind

### Description

The kind of the target

## .spec.distribution.customPatches.patches.target.labelSelector

### Description

The label selector of the target

## .spec.distribution.customPatches.patches.target.name

### Description

The name of the target

## .spec.distribution.customPatches.patches.target.namespace

### Description

The namespace of the target

## .spec.distribution.customPatches.patches.target.version

### Description

The version of the target

## .spec.distribution.customPatches.patchesStrategicMerge

### Description

Each entry should be either a relative file path or an inline content resolving to a partial or complete resource definition

## .spec.distribution.customPatches.secretGenerator

### Properties

| Property                                                            | Type     | Required |
|:--------------------------------------------------------------------|:---------|:---------|
| [behavior](#specdistributioncustompatchessecretgeneratorbehavior)   | `string` | Optional |
| [envs](#specdistributioncustompatchessecretgeneratorenvs)           | `array`  | Optional |
| [files](#specdistributioncustompatchessecretgeneratorfiles)         | `array`  | Optional |
| [literals](#specdistributioncustompatchessecretgeneratorliterals)   | `array`  | Optional |
| [name](#specdistributioncustompatchessecretgeneratorname)           | `string` | Required |
| [namespace](#specdistributioncustompatchessecretgeneratornamespace) | `string` | Optional |
| [options](#specdistributioncustompatchessecretgeneratoroptions)     | `object` | Optional |
| [type](#specdistributioncustompatchessecretgeneratortype)           | `string` | Optional |

## .spec.distribution.customPatches.secretGenerator.behavior

### Description

The behavior of the secret

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value     |
|:----------|
|`"create"` |
|`"replace"`|
|`"merge"`  |

## .spec.distribution.customPatches.secretGenerator.envs

### Description

The envs of the secret

## .spec.distribution.customPatches.secretGenerator.files

### Description

The files of the secret

## .spec.distribution.customPatches.secretGenerator.literals

### Description

The literals of the secret

## .spec.distribution.customPatches.secretGenerator.name

### Description

The name of the secret

## .spec.distribution.customPatches.secretGenerator.namespace

### Description

The namespace of the secret

## .spec.distribution.customPatches.secretGenerator.options

### Properties

| Property                                                                                           | Type      | Required |
|:---------------------------------------------------------------------------------------------------|:----------|:---------|
| [annotations](#specdistributioncustompatchessecretgeneratoroptionsannotations)                     | `object`  | Optional |
| [disableNameSuffixHash](#specdistributioncustompatchessecretgeneratoroptionsdisablenamesuffixhash) | `boolean` | Optional |
| [immutable](#specdistributioncustompatchessecretgeneratoroptionsimmutable)                         | `boolean` | Optional |
| [labels](#specdistributioncustompatchessecretgeneratoroptionslabels)                               | `object`  | Optional |

## .spec.distribution.customPatches.secretGenerator.options.annotations

### Description

The annotations of the secret

## .spec.distribution.customPatches.secretGenerator.options.disableNameSuffixHash

### Description

If true, the name suffix hash will be disabled

## .spec.distribution.customPatches.secretGenerator.options.immutable

### Description

If true, the secret will be immutable

## .spec.distribution.customPatches.secretGenerator.options.labels

### Description

The labels of the secret

## .spec.distribution.customPatches.secretGenerator.type

### Description

The type of the secret

## .spec.distribution.modules

### Properties

| Property                                         | Type     | Required |
|:-------------------------------------------------|:---------|:---------|
| [auth](#specdistributionmodulesauth)             | `object` | Required |
| [dr](#specdistributionmodulesdr)                 | `object` | Required |
| [ingress](#specdistributionmodulesingress)       | `object` | Required |
| [logging](#specdistributionmoduleslogging)       | `object` | Required |
| [monitoring](#specdistributionmodulesmonitoring) | `object` | Required |
| [networking](#specdistributionmodulesnetworking) | `object` | Required |
| [policy](#specdistributionmodulespolicy)         | `object` | Required |
| [tracing](#specdistributionmodulestracing)       | `object` | Optional |

### Description

KFD modules configuration.

## .spec.distribution.modules.auth

### Properties

| Property                                         | Type     | Required |
|:-------------------------------------------------|:---------|:---------|
| [provider](#specdistributionmodulesauthprovider) | `object` | Required |

### Description

Authentication provider configuration.

## .spec.distribution.modules.auth.provider

### Properties

| Property                                         | Type     | Required |
|:-------------------------------------------------|:---------|:---------|
| [type](#specdistributionmodulesauthprovidertype) | `string` | Required |

## .spec.distribution.modules.auth.provider.type

### Description

Authentication provider type.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value       |
|:------------|
|`"none"`     |
|`"basicAuth"`|
|`"sso"`      |

## .spec.distribution.modules.dr

### Properties

| Property                                   | Type     | Required |
|:-------------------------------------------|:---------|:---------|
| [type](#specdistributionmodulesdrtype)     | `string` | Required |
| [velero](#specdistributionmodulesdrvelero) | `object` | Optional |

### Description

Disaster recovery configuration. Ref: https://velero.io/docs/

## .spec.distribution.modules.dr.type

### Description

DR backend type.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value         |
|:--------------|
|`"on-premises"`|
|`"none"`       |

## .spec.distribution.modules.dr.velero

### Properties

| Property                                               | Type     | Required |
|:-------------------------------------------------------|:---------|:---------|
| [backend](#specdistributionmodulesdrvelerobackend)     | `string` | Optional |
| [s3](#specdistributionmodulesdrveleros3)               | `object` | Optional |
| [schedules](#specdistributionmodulesdrveleroschedules) | `array`  | Optional |

## .spec.distribution.modules.dr.velero.backend

### Description

Backup storage backend.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value   |
|:--------|
|`"s3"`   |
|`"minio"`|

## .spec.distribution.modules.dr.velero.s3

### Properties

| Property                                                   | Type     | Required |
|:-----------------------------------------------------------|:---------|:---------|
| [bucketName](#specdistributionmodulesdrveleros3bucketname) | `string` | Optional |
| [endpoint](#specdistributionmodulesdrveleros3endpoint)     | `string` | Optional |
| [region](#specdistributionmodulesdrveleros3region)         | `string` | Optional |

## .spec.distribution.modules.dr.velero.s3.bucketName

### Description

S3 bucket name (3-63 chars, lowercase, no underscores). Example: production-cluster-backups

### Constraints

**maximum length**: the maximum number of characters for this string is: `63`

**minimum length**: the minimum number of characters for this string is: `3`

**pattern**: the string must match the following regular expression:

```regexp
^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$
```

[try pattern](https://regexr.com/?expression=^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$)

## .spec.distribution.modules.dr.velero.s3.endpoint

### Description

S3 endpoint URL.

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^(http|https)\:\/\/.+$
```

[try pattern](https://regexr.com/?expression=^\(http|https\)\:\\/\\/.%2B$)

## .spec.distribution.modules.dr.velero.s3.region

### Description

S3 region.

## .spec.distribution.modules.dr.velero.schedules

### Properties

| Property                                                      | Type     | Required |
|:--------------------------------------------------------------|:---------|:---------|
| [name](#specdistributionmodulesdrveleroschedulesname)         | `string` | Required |
| [schedule](#specdistributionmodulesdrveleroschedulesschedule) | `string` | Required |
| [ttl](#specdistributionmodulesdrveleroschedulesttl)           | `string` | Required |

## .spec.distribution.modules.dr.velero.schedules.name

### Description

Schedule name.

## .spec.distribution.modules.dr.velero.schedules.schedule

### Description

Cron expression (standard 5-field format). Examples: 0 3 * * *, */5 * * * *, @daily

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^(@(annually|yearly|monthly|weekly|daily|hourly|reboot))|(@every (\d+(ns|us|µs|ms|s|m|h))+)|(((\d+,)+\d+|(\d+([/-])\d+)|\d+|\*) +){4}((\d+,)+\d+|(\d+([/-])\d+)|\d+|\*)$
```

[try pattern](https://regexr.com/?expression=^\(@\(annually|yearly|monthly|weekly|daily|hourly|reboot\)\)|\(@every \(\d%2B\(ns|us|µs|ms|s|m|h\)\)%2B\)|\(\(\(\d%2B,\)%2B\d%2B|\(\d%2B\([\/-]\)\d%2B\)|\d%2B|\*\) %2B\){4}\(\(\d%2B,\)%2B\d%2B|\(\d%2B\([\/-]\)\d%2B\)|\d%2B|\*\)$)

## .spec.distribution.modules.dr.velero.schedules.ttl

### Description

Duration format with unit suffix. Examples: 720h, 15d, 30m, 5s

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(ns|us|µs|ms|s|m|h|d)$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(ns|us|µs|ms|s|m|h|d\)$)

## .spec.distribution.modules.ingress

### Properties

| Property                                                  | Type     | Required |
|:----------------------------------------------------------|:---------|:---------|
| [baseDomain](#specdistributionmodulesingressbasedomain)   | `string` | Required |
| [certManager](#specdistributionmodulesingresscertmanager) | `object` | Optional |
| [nginx](#specdistributionmodulesingressnginx)             | `object` | Required |

### Description

Ingress controller configuration. Ref: https://kubernetes.github.io/ingress-nginx/

## .spec.distribution.modules.ingress.baseDomain

### Description

Base domain for ingresses (lowercase). Example: example.com

### Constraints

**maximum length**: the maximum number of characters for this string is: `253`

**pattern**: the string must match the following regular expression:

```regexp
^([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,}$
```

[try pattern](https://regexr.com/?expression=^\([a-z0-9]\([a-z0-9-]{0,61}[a-z0-9]\)?\.\)%2B[a-z]{2,}$)

## .spec.distribution.modules.ingress.certManager

### Properties

| Property                                                                 | Type     | Required |
|:-------------------------------------------------------------------------|:---------|:---------|
| [clusterIssuer](#specdistributionmodulesingresscertmanagerclusterissuer) | `object` | Required |

## .spec.distribution.modules.ingress.certManager.clusterIssuer

### Properties

| Property                                                              | Type     | Required |
|:----------------------------------------------------------------------|:---------|:---------|
| [email](#specdistributionmodulesingresscertmanagerclusterissueremail) | `string` | Required |
| [name](#specdistributionmodulesingresscertmanagerclusterissuername)   | `string` | Required |
| [type](#specdistributionmodulesingresscertmanagerclusterissuertype)   | `string` | Required |

## .spec.distribution.modules.ingress.certManager.clusterIssuer.email

### Description

Email for Let's Encrypt.

## .spec.distribution.modules.ingress.certManager.clusterIssuer.name

### Description

Cluster issuer name.

## .spec.distribution.modules.ingress.certManager.clusterIssuer.type

### Description

Challenge type.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"http01"`|

## .spec.distribution.modules.ingress.nginx

### Properties

| Property                                         | Type     | Required |
|:-------------------------------------------------|:---------|:---------|
| [tls](#specdistributionmodulesingressnginxtls)   | `object` | Optional |
| [type](#specdistributionmodulesingressnginxtype) | `string` | Required |

## .spec.distribution.modules.ingress.nginx.tls

### Properties

| Property                                                    | Type     | Required |
|:------------------------------------------------------------|:---------|:---------|
| [provider](#specdistributionmodulesingressnginxtlsprovider) | `string` | Required |

## .spec.distribution.modules.ingress.nginx.tls.provider

### Description

TLS certificate provider.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value         |
|:--------------|
|`"certManager"`|
|`"secret"`     |
|`"none"`       |

## .spec.distribution.modules.ingress.nginx.type

### Description

Nginx ingress controller type.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"single"`|
|`"dual"`  |
|`"none"`  |

## .spec.distribution.modules.logging

### Properties

| Property                                      | Type     | Required |
|:----------------------------------------------|:---------|:---------|
| [loki](#specdistributionmodulesloggingloki)   | `object` | Optional |
| [minio](#specdistributionmodulesloggingminio) | `object` | Optional |
| [type](#specdistributionmodulesloggingtype)   | `string` | Required |

### Description

Logging stack configuration. Ref: https://grafana.com/docs/loki/latest/

## .spec.distribution.modules.logging.loki

### Properties

| Property                                                              | Type     | Required |
|:----------------------------------------------------------------------|:---------|:---------|
| [retentionPeriod](#specdistributionmoduleslogginglokiretentionperiod) | `string` | Optional |
| [storage](#specdistributionmoduleslogginglokistorage)                 | `object` | Optional |

## .spec.distribution.modules.logging.loki.retentionPeriod

### Description

Duration format with unit suffix. Examples: 720h, 15d, 30m, 5s

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(ns|us|µs|ms|s|m|h|d)$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(ns|us|µs|ms|s|m|h|d\)$)

## .spec.distribution.modules.logging.loki.storage

### Properties

| Property                                               | Type     | Required |
|:-------------------------------------------------------|:---------|:---------|
| [size](#specdistributionmoduleslogginglokistoragesize) | `string` | Optional |

## .spec.distribution.modules.logging.loki.storage.size

### Description

Kubernetes resource quantity format. Examples: 50Gi, 100Mi, 1Ti

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk])$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk]\)$)

## .spec.distribution.modules.logging.minio

### Properties

| Property                                                       | Type     | Required |
|:---------------------------------------------------------------|:---------|:---------|
| [storageSize](#specdistributionmodulesloggingminiostoragesize) | `string` | Optional |

## .spec.distribution.modules.logging.minio.storageSize

### Description

Kubernetes resource quantity format. Examples: 50Gi, 100Mi, 1Ti

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk])$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk]\)$)

## .spec.distribution.modules.logging.type

### Description

Logging backend type.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value        |
|:-------------|
|`"loki"`      |
|`"opensearch"`|
|`"none"`      |

## .spec.distribution.modules.monitoring

### Properties

| Property                                                                 | Type     | Required |
|:-------------------------------------------------------------------------|:---------|:---------|
| [alertmanager](#specdistributionmodulesmonitoringalertmanager)           | `object` | Optional |
| [prometheus](#specdistributionmodulesmonitoringprometheus)               | `object` | Optional |
| [prometheusAdapter](#specdistributionmodulesmonitoringprometheusadapter) | `object` | Optional |
| [type](#specdistributionmodulesmonitoringtype)                           | `string` | Required |

### Description

Monitoring stack configuration. Ref: https://prometheus.io/docs/introduction/overview/

## .spec.distribution.modules.monitoring.alertmanager

### Properties

| Property                                                                                 | Type      | Required |
|:-----------------------------------------------------------------------------------------|:----------|:---------|
| [deadMansSwitch](#specdistributionmodulesmonitoringalertmanagerdeadmansswitch)           | `object`  | Optional |
| [installDefaultRules](#specdistributionmodulesmonitoringalertmanagerinstalldefaultrules) | `boolean` | Optional |

## .spec.distribution.modules.monitoring.alertmanager.deadMansSwitch

### Properties

| Property                                                                       | Type      | Required |
|:-------------------------------------------------------------------------------|:----------|:---------|
| [enabled](#specdistributionmodulesmonitoringalertmanagerdeadmansswitchenabled) | `boolean` | Optional |

## .spec.distribution.modules.monitoring.alertmanager.deadMansSwitch.enabled

### Description

Enable dead man's switch.

## .spec.distribution.modules.monitoring.alertmanager.installDefaultRules

### Description

Install default alerting rules.

## .spec.distribution.modules.monitoring.prometheus

### Properties

| Property                                                                   | Type     | Required |
|:---------------------------------------------------------------------------|:---------|:---------|
| [retentionSize](#specdistributionmodulesmonitoringprometheusretentionsize) | `string` | Optional |
| [retentionTime](#specdistributionmodulesmonitoringprometheusretentiontime) | `string` | Optional |
| [storageSize](#specdistributionmodulesmonitoringprometheusstoragesize)     | `string` | Optional |

## .spec.distribution.modules.monitoring.prometheus.retentionSize

### Description

Kubernetes resource quantity format. Examples: 50Gi, 100Mi, 1Ti

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk])$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk]\)$)

## .spec.distribution.modules.monitoring.prometheus.retentionTime

### Description

Duration format with unit suffix. Examples: 720h, 15d, 30m, 5s

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(ns|us|µs|ms|s|m|h|d)$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(ns|us|µs|ms|s|m|h|d\)$)

## .spec.distribution.modules.monitoring.prometheus.storageSize

### Description

Kubernetes resource quantity format. Examples: 50Gi, 100Mi, 1Ti

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk])$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk]\)$)

## .spec.distribution.modules.monitoring.prometheusAdapter

### Properties

| Property                                                                                                  | Type      | Required |
|:----------------------------------------------------------------------------------------------------------|:----------|:---------|
| [installEnhancedHPAMetrics](#specdistributionmodulesmonitoringprometheusadapterinstallenhancedhpametrics) | `boolean` | Optional |
| [resources](#specdistributionmodulesmonitoringprometheusadapterresources)                                 | `object`  | Optional |

## .spec.distribution.modules.monitoring.prometheusAdapter.installEnhancedHPAMetrics

### Description

Install enhanced HPA metrics.

## .spec.distribution.modules.monitoring.prometheusAdapter.resources

### Properties

| Property                                                                         | Type     | Required |
|:---------------------------------------------------------------------------------|:---------|:---------|
| [limits](#specdistributionmodulesmonitoringprometheusadapterresourceslimits)     | `object` | Optional |
| [requests](#specdistributionmodulesmonitoringprometheusadapterresourcesrequests) | `object` | Optional |

## .spec.distribution.modules.monitoring.prometheusAdapter.resources.limits

### Properties

| Property                                                                           | Type     | Required |
|:-----------------------------------------------------------------------------------|:---------|:---------|
| [cpu](#specdistributionmodulesmonitoringprometheusadapterresourceslimitscpu)       | `string` | Optional |
| [memory](#specdistributionmodulesmonitoringprometheusadapterresourceslimitsmemory) | `string` | Optional |

## .spec.distribution.modules.monitoring.prometheusAdapter.resources.limits.cpu

### Description

The CPU limit for the Pod, in cores or millicores. Examples: 1000m, 2, 1.5

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(m|)$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(m|\)$)

## .spec.distribution.modules.monitoring.prometheusAdapter.resources.limits.memory

### Description

Kubernetes resource quantity format. Examples: 50Gi, 100Mi, 1Ti

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk])$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk]\)$)

## .spec.distribution.modules.monitoring.prometheusAdapter.resources.requests

### Properties

| Property                                                                             | Type     | Required |
|:-------------------------------------------------------------------------------------|:---------|:---------|
| [cpu](#specdistributionmodulesmonitoringprometheusadapterresourcesrequestscpu)       | `string` | Optional |
| [memory](#specdistributionmodulesmonitoringprometheusadapterresourcesrequestsmemory) | `string` | Optional |

## .spec.distribution.modules.monitoring.prometheusAdapter.resources.requests.cpu

### Description

The CPU request for the Pod, in cores or millicores. Examples: 500m, 1, 0.5

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(m|)$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(m|\)$)

## .spec.distribution.modules.monitoring.prometheusAdapter.resources.requests.memory

### Description

Kubernetes resource quantity format. Examples: 50Gi, 100Mi, 1Ti

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk])$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk]\)$)

## .spec.distribution.modules.monitoring.type

### Description

Monitoring backend type.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value             |
|:------------------|
|`"prometheus"`     |
|`"prometheusAgent"`|
|`"mimir"`          |
|`"none"`           |

## .spec.distribution.modules.networking

### Properties

| Property                                       | Type     | Required |
|:-----------------------------------------------|:---------|:---------|
| [type](#specdistributionmodulesnetworkingtype) | `string` | Required |

### Description

CNI plugin configuration. Ref: https://docs.tigera.io/calico/latest/about/

## .spec.distribution.modules.networking.type

### Description

CNI plugin type.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"calico"`|
|`"cilium"`|
|`"none"`  |

## .spec.distribution.modules.policy

### Properties

| Property                                         | Type     | Required |
|:-------------------------------------------------|:---------|:---------|
| [kyverno](#specdistributionmodulespolicykyverno) | `object` | Optional |
| [type](#specdistributionmodulespolicytype)       | `string` | Required |

### Description

Policy engine configuration. Ref: https://kyverno.io/docs/

## .spec.distribution.modules.policy.kyverno

### Properties

| Property                                                                                | Type      | Required |
|:----------------------------------------------------------------------------------------|:----------|:---------|
| [installDefaultPolicies](#specdistributionmodulespolicykyvernoinstalldefaultpolicies)   | `boolean` | Optional |
| [validationFailureAction](#specdistributionmodulespolicykyvernovalidationfailureaction) | `string`  | Optional |

## .spec.distribution.modules.policy.kyverno.installDefaultPolicies

### Description

Install default Kyverno policies.

## .spec.distribution.modules.policy.kyverno.validationFailureAction

### Description

Default action for validation failures.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value     |
|:----------|
|`"Audit"`  |
|`"Enforce"`|

## .spec.distribution.modules.policy.type

### Description

Policy engine type.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value        |
|:-------------|
|`"kyverno"`   |
|`"gatekeeper"`|
|`"none"`      |

## .spec.distribution.modules.tracing

### Properties

| Property                                      | Type     | Required |
|:----------------------------------------------|:---------|:---------|
| [tempo](#specdistributionmodulestracingtempo) | `object` | Optional |
| [type](#specdistributionmodulestracingtype)   | `string` | Required |

### Description

Tracing configuration. Ref: https://grafana.com/docs/tempo/latest/

## .spec.distribution.modules.tracing.tempo

### Properties

| Property                                                           | Type     | Required |
|:-------------------------------------------------------------------|:---------|:---------|
| [retentionTime](#specdistributionmodulestracingtemporetentiontime) | `string` | Optional |

## .spec.distribution.modules.tracing.tempo.retentionTime

### Description

Duration format with unit suffix. Examples: 720h, 15d, 30m, 5s

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(ns|us|µs|ms|s|m|h|d)$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(ns|us|µs|ms|s|m|h|d\)$)

## .spec.distribution.modules.tracing.type

### Description

Tracing backend type.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value   |
|:--------|
|`"tempo"`|
|`"none"` |

## .spec.distributionVersion

### Description

Defines which KFD version will be installed and, in consequence, the Kubernetes version used to create the cluster. It supports git tags and branches. Example: `v1.32.1`.

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.infrastructure

### Properties

| Property                                                | Type     | Required |
|:--------------------------------------------------------|:---------|:---------|
| [ipxeServer](#specinfrastructureipxeserver)             | `object` | Optional |
| [kernelParameters](#specinfrastructurekernelparameters) | `array`  | Optional |
| [nodes](#specinfrastructurenodes)                       | `array`  | Required |
| [proxy](#specinfrastructureproxy)                       | `object` | Optional |
| [ssh](#specinfrastructuressh)                           | `object` | Required |

### Description

Defines the bare metal infrastructure configuration, including nodes, network boot, storage, and networking.

## .spec.infrastructure.ipxeServer

### Properties

| Property                                          | Type     | Required |
|:--------------------------------------------------|:---------|:---------|
| [advanced](#specinfrastructureipxeserveradvanced) | `object` | Optional |
| [url](#specinfrastructureipxeserverurl)           | `string` | Required |

### Description

iPXE server configuration for network boot provisioning. Ref: https://www.flatcar.org/docs/latest/setup/customization/

## .spec.infrastructure.ipxeServer.advanced

### Properties

| Property                                                      | Type     | Required |
|:--------------------------------------------------------------|:---------|:---------|
| [assetsPath](#specinfrastructureipxeserveradvancedassetspath) | `string` | Optional |
| [dataPath](#specinfrastructureipxeserveradvanceddatapath)     | `string` | Optional |
| [logLevel](#specinfrastructureipxeserveradvancedloglevel)     | `string` | Optional |

## .spec.infrastructure.ipxeServer.advanced.assetsPath

### Description

Path to the iPXE server assets directory. Example: /var/lib/ipxe-server/assets

## .spec.infrastructure.ipxeServer.advanced.dataPath

### Description

Path to the iPXE server data directory. Example: /var/lib/ipxe-server

## .spec.infrastructure.ipxeServer.advanced.logLevel

### Description

Log level for the iPXE server. Example: info

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value     |
|:----------|
|`"debug"`  |
|`"info"`   |
|`"warning"`|
|`"error"`  |

## .spec.infrastructure.ipxeServer.url

### Description

The URL of the iPXE boot server. Example: https://ipxe.internal.example.com:8080

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^(http|https)\:\/\/.+$
```

[try pattern](https://regexr.com/?expression=^\(http|https\)\:\\/\\/.%2B$)

## .spec.infrastructure.kernelParameters

### Properties

| Property                                          | Type     | Required |
|:--------------------------------------------------|:---------|:---------|
| [name](#specinfrastructurekernelparametersname)   | `string` | Required |
| [value](#specinfrastructurekernelparametersvalue) | `string` | Required |

### Description

Global kernel parameters applied to all nodes at infrastructure level. Node-specific parameters override these global values. Ref: https://kubernetes.io/docs/tasks/administer-cluster/sysctl-cluster/

## .spec.infrastructure.kernelParameters.name

### Description

The kernel parameter name (sysctl format). Example: net.ipv4.ip_forward, net.bridge.bridge-nf-call-iptables

### Constraints

**maximum length**: the maximum number of characters for this string is: `256`

**minimum length**: the minimum number of characters for this string is: `1`

**pattern**: the string must match the following regular expression:

```regexp
^[a-z][a-z0-9_-]*([.][a-z][a-z0-9_-]*)+$
```

[try pattern](https://regexr.com/?expression=^[a-z][a-z0-9_-]*\([.][a-z][a-z0-9_-]*\)%2B$)

## .spec.infrastructure.kernelParameters.value

### Description

The kernel parameter value. Example: "1"

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.infrastructure.nodes

### Properties

| Property                                                     | Type     | Required |
|:-------------------------------------------------------------|:---------|:---------|
| [arch](#specinfrastructurenodesarch)                         | `string` | Optional |
| [hostname](#specinfrastructurenodeshostname)                 | `string` | Required |
| [iscsi](#specinfrastructurenodesiscsi)                       | `object` | Optional |
| [kernelParameters](#specinfrastructurenodeskernelparameters) | `array`  | Optional |
| [macAddress](#specinfrastructurenodesmacaddress)             | `string` | Required |
| [multipath](#specinfrastructurenodesmultipath)               | `object` | Optional |
| [network](#specinfrastructurenodesnetwork)                   | `object` | Required |
| [storage](#specinfrastructurenodesstorage)                   | `object` | Required |

### Description

Definition of a bare metal node with storage, network, and hardware configuration.

### Constraints

**minimum number of items**: the minimum number of items for this array is: `1`

## .spec.infrastructure.nodes.arch

### Description

CPU architecture for the node. Determines which sysext packages are downloaded. Example: x86-64, arm64

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"x86-64"`|
|`"arm64"` |

## .spec.infrastructure.nodes.hostname

### Description

Fully qualified domain name for the node. Example: node01.k8s.example.com

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

**pattern**: the string must match the following regular expression:

```regexp
^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$
```

[try pattern](https://regexr.com/?expression=^\([a-zA-Z0-9]\([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]\)?\.\)%2B[a-zA-Z]{2,}$)

## .spec.infrastructure.nodes.iscsi

### Properties

| Property                                        | Type      | Required |
|:------------------------------------------------|:----------|:---------|
| [config](#specinfrastructurenodesiscsiconfig)   | `string`  | Optional |
| [enabled](#specinfrastructurenodesiscsienabled) | `boolean` | Required |

### Description

iSCSI initiator configuration. Ref: https://www.flatcar.org/docs/latest/setup/customization/other-settings/

## .spec.infrastructure.nodes.iscsi.config

### Description

iSCSI configuration content (required when enabled=true).

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.infrastructure.nodes.iscsi.enabled

### Description

Enable iSCSI support on this node.

## .spec.infrastructure.nodes.kernelParameters

### Properties

| Property                                               | Type     | Required |
|:-------------------------------------------------------|:---------|:---------|
| [name](#specinfrastructurenodeskernelparametersname)   | `string` | Required |
| [value](#specinfrastructurenodeskernelparametersvalue) | `string` | Required |

### Description

Node-specific kernel parameters that override global settings.

## .spec.infrastructure.nodes.kernelParameters.name

### Description

The kernel parameter name (sysctl format). Example: net.ipv4.ip_forward, net.bridge.bridge-nf-call-iptables

### Constraints

**maximum length**: the maximum number of characters for this string is: `256`

**minimum length**: the minimum number of characters for this string is: `1`

**pattern**: the string must match the following regular expression:

```regexp
^[a-z][a-z0-9_-]*([.][a-z][a-z0-9_-]*)+$
```

[try pattern](https://regexr.com/?expression=^[a-z][a-z0-9_-]*\([.][a-z][a-z0-9_-]*\)%2B$)

## .spec.infrastructure.nodes.kernelParameters.value

### Description

The kernel parameter value. Example: "1"

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.infrastructure.nodes.macAddress

### Description

MAC address in format XX:XX:XX:XX:XX:XX

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^([0-9A-Fa-f]{2}:){5}([0-9A-Fa-f]{2})$
```

[try pattern](https://regexr.com/?expression=^\([0-9A-Fa-f]{2}:\){5}\([0-9A-Fa-f]{2}\)$)

## .spec.infrastructure.nodes.multipath

### Properties

| Property                                            | Type      | Required |
|:----------------------------------------------------|:----------|:---------|
| [config](#specinfrastructurenodesmultipathconfig)   | `string`  | Optional |
| [enabled](#specinfrastructurenodesmultipathenabled) | `boolean` | Required |

### Description

DM-Multipath configuration for redundant storage paths.

## .spec.infrastructure.nodes.multipath.config

### Description

Multipath configuration content (required when enabled=true).

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.infrastructure.nodes.multipath.enabled

### Description

Enable multipath support on this node.

## .spec.infrastructure.nodes.network

### Properties

| Property                                              | Type     | Required |
|:------------------------------------------------------|:---------|:---------|
| [bonds](#specinfrastructurenodesnetworkbonds)         | `object` | Optional |
| [ethernets](#specinfrastructurenodesnetworkethernets) | `object` | Optional |

### Description

Advanced network configuration with ethernets, bonds, and VLANs using networkd format.

## .spec.infrastructure.nodes.network.bonds

### Description

Bond interface configurations, keyed by bond name (e.g., bond0, bond1).

## .spec.infrastructure.nodes.network.ethernets

### Description

Ethernet interface configurations, keyed by interface name (e.g., eth0, ens3, eno49).

## .spec.infrastructure.nodes.storage

### Properties

| Property                                                          | Type     | Required |
|:------------------------------------------------------------------|:---------|:---------|
| [additionalDisks](#specinfrastructurenodesstorageadditionaldisks) | `array`  | Optional |
| [installDisk](#specinfrastructurenodesstorageinstalldisk)         | `string` | Required |

### Description

Storage configuration for the node, including install disk and additional disks with partitions.

## .spec.infrastructure.nodes.storage.additionalDisks

### Properties

| Property                                                               | Type     | Required |
|:-----------------------------------------------------------------------|:---------|:---------|
| [device](#specinfrastructurenodesstorageadditionaldisksdevice)         | `string` | Required |
| [partitions](#specinfrastructurenodesstorageadditionaldiskspartitions) | `array`  | Required |

### Description

Additional disk configuration with partitions.

## .spec.infrastructure.nodes.storage.additionalDisks.device

### Description

Unix device path. Example: /dev/sda, /dev/nvme0n1

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^/dev/[a-zA-Z0-9/]+$
```

[try pattern](https://regexr.com/?expression=^\/dev\/[a-zA-Z0-9\/]%2B$)

## .spec.infrastructure.nodes.storage.additionalDisks.partitions

### Properties

| Property                                                                         | Type      | Required |
|:---------------------------------------------------------------------------------|:----------|:---------|
| [filesystem](#specinfrastructurenodesstorageadditionaldiskspartitionsfilesystem) | `object`  | Required |
| [label](#specinfrastructurenodesstorageadditionaldiskspartitionslabel)           | `string`  | Required |
| [number](#specinfrastructurenodesstorageadditionaldiskspartitionsnumber)         | `integer` | Required |
| [sizeMiB](#specinfrastructurenodesstorageadditionaldiskspartitionssizemib)       | `integer` | Required |

### Description

Partition definition with filesystem and mount options.

### Constraints

**minimum number of items**: the minimum number of items for this array is: `1`

## .spec.infrastructure.nodes.storage.additionalDisks.partitions.filesystem

### Properties

| Property                                                                                       | Type     | Required |
|:-----------------------------------------------------------------------------------------------|:---------|:---------|
| [format](#specinfrastructurenodesstorageadditionaldiskspartitionsfilesystemformat)             | `string` | Required |
| [label](#specinfrastructurenodesstorageadditionaldiskspartitionsfilesystemlabel)               | `string` | Required |
| [mountOptions](#specinfrastructurenodesstorageadditionaldiskspartitionsfilesystemmountoptions) | `array`  | Optional |
| [mountPoint](#specinfrastructurenodesstorageadditionaldiskspartitionsfilesystemmountpoint)     | `string` | Required |

### Description

Filesystem configuration for a partition.

## .spec.infrastructure.nodes.storage.additionalDisks.partitions.filesystem.format

### Description

Filesystem type

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value   |
|:--------|
|`"ext4"` |
|`"xfs"`  |
|`"btrfs"`|
|`"ext3"` |
|`"vfat"` |

## .spec.infrastructure.nodes.storage.additionalDisks.partitions.filesystem.label

### Description

Filesystem label (max 12 chars for XFS compatibility). Example: ETCD

### Constraints

**maximum length**: the maximum number of characters for this string is: `12`

**minimum length**: the minimum number of characters for this string is: `1`

**pattern**: the string must match the following regular expression:

```regexp
^[A-Z0-9_-]+$
```

[try pattern](https://regexr.com/?expression=^[A-Z0-9_-]%2B$)

## .spec.infrastructure.nodes.storage.additionalDisks.partitions.filesystem.mountOptions

### Description

Mount options (validated safe options only). Example: ["noatime", "nodiratime"]

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value         |
|:--------------|
|`"noatime"`    |
|`"nodiratime"` |
|`"relatime"`   |
|`"strictatime"`|
|`"nodev"`      |
|`"nosuid"`     |
|`"noexec"`     |
|`"ro"`         |
|`"rw"`         |
|`"sync"`       |
|`"async"`      |
|`"discard"`    |
|`"nodiscard"`  |
|`"defaults"`   |

## .spec.infrastructure.nodes.storage.additionalDisks.partitions.filesystem.mountPoint

### Description

Mount point path. Example: /var/lib/etcd

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^/[a-zA-Z0-9/_-]*$
```

[try pattern](https://regexr.com/?expression=^\/[a-zA-Z0-9\/_-]*$)

## .spec.infrastructure.nodes.storage.additionalDisks.partitions.label

### Description

Partition label. Example: etcd-data

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.infrastructure.nodes.storage.additionalDisks.partitions.number

### Description

Partition number. Example: 1

## .spec.infrastructure.nodes.storage.additionalDisks.partitions.sizeMiB

### Description

Partition size in MiB. Use 0 to use all available space.

## .spec.infrastructure.nodes.storage.installDisk

### Description

Unix device path. Example: /dev/sda, /dev/nvme0n1

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^/dev/[a-zA-Z0-9/]+$
```

[try pattern](https://regexr.com/?expression=^\/dev\/[a-zA-Z0-9\/]%2B$)

## .spec.infrastructure.proxy

### Properties

| Property                                   | Type     | Required |
|:-------------------------------------------|:---------|:---------|
| [http](#specinfrastructureproxyhttp)       | `string` | Optional |
| [https](#specinfrastructureproxyhttps)     | `string` | Optional |
| [noProxy](#specinfrastructureproxynoproxy) | `string` | Optional |

### Description

HTTP/HTTPS proxy configuration for the infrastructure nodes.

## .spec.infrastructure.proxy.http

### Description

The HTTP proxy URL. Example: http://proxy.example.com:3128

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^(http|https)\:\/\/.+$
```

[try pattern](https://regexr.com/?expression=^\(http|https\)\:\\/\\/.%2B$)

## .spec.infrastructure.proxy.https

### Description

The HTTPS proxy URL. Example: https://proxy.example.com:3128

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^(http|https)\:\/\/.+$
```

[try pattern](https://regexr.com/?expression=^\(http|https\)\:\\/\\/.%2B$)

## .spec.infrastructure.proxy.noProxy

### Description

Comma-separated list of hosts that should not use the HTTP(S) proxy. Example: localhost,127.0.0.1,10.0.0.0/8,.example.com

## .spec.infrastructure.ssh

### Properties

| Property                                   | Type     | Required |
|:-------------------------------------------|:---------|:---------|
| [keyPath](#specinfrastructuresshkeypath)   | `string` | Required |
| [username](#specinfrastructuresshusername) | `string` | Required |

### Description

SSH credentials for node access.

## .spec.infrastructure.ssh.keyPath

### Description

Path to the SSH private key. Example: ~/.ssh/id_ed25519_production

## .spec.infrastructure.ssh.username

### Description

SSH username. Example: core

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.kubernetes

### Properties

| Property                                      | Type     | Required |
|:----------------------------------------------|:---------|:---------|
| [advanced](#speckubernetesadvanced)           | `object` | Optional |
| [controlPlane](#speckubernetescontrolplane)   | `object` | Required |
| [etcd](#speckubernetesetcd)                   | `object` | Required |
| [loadBalancers](#speckubernetesloadbalancers) | `object` | Optional |
| [networking](#speckubernetesnetworking)       | `object` | Required |
| [nodeGroups](#speckubernetesnodegroups)       | `array`  | Optional |
| [version](#speckubernetesversion)             | `string` | Optional |

### Description

Kubernetes cluster configuration including control plane, etcd, and worker nodes.

## .spec.kubernetes.advanced

### Properties

| Property                                                            | Type     | Required |
|:--------------------------------------------------------------------|:---------|:---------|
| [apiServer](#speckubernetesadvancedapiserver)                       | `object` | Optional |
| [cloud](#speckubernetesadvancedcloud)                               | `object` | Optional |
| [containerd](#speckubernetesadvancedcontainerd)                     | `object` | Optional |
| [encryption](#speckubernetesadvancedencryption)                     | `object` | Optional |
| [kubeletConfiguration](#speckubernetesadvancedkubeletconfiguration) | `object` | Optional |
| [oidc](#speckubernetesadvancedoidc)                                 | `object` | Optional |
| [users](#speckubernetesadvancedusers)                               | `object` | Optional |

### Description

Advanced Kubernetes cluster configuration.

## .spec.kubernetes.advanced.apiServer

### Properties

| Property                                             | Type    | Required |
|:-----------------------------------------------------|:--------|:---------|
| [certSANs](#speckubernetesadvancedapiservercertsans) | `array` | Optional |

### Description

API server configuration for certificate Subject Alternative Names.

## .spec.kubernetes.advanced.apiServer.certSANs

### Description

SAN entry (hostname or IP address). Examples: k8s-api.example.com, 192.168.100.100

## .spec.kubernetes.advanced.cloud

### Properties

| Property                                         | Type     | Required |
|:-------------------------------------------------|:---------|:---------|
| [provider](#speckubernetesadvancedcloudprovider) | `string` | Optional |

### Description

Cloud provider integration. Ref: https://kubernetes.io/docs/concepts/architecture/cloud-controller/

## .spec.kubernetes.advanced.cloud.provider

### Description

Cloud provider type. Example: external

## .spec.kubernetes.advanced.containerd

### Properties

| Property                                                            | Type    | Required |
|:--------------------------------------------------------------------|:--------|:---------|
| [registryConfigs](#speckubernetesadvancedcontainerdregistryconfigs) | `array` | Optional |

### Description

Container runtime registry configuration.

## .spec.kubernetes.advanced.containerd.registryConfigs

### Properties

| Property                                                                                 | Type      | Required |
|:-----------------------------------------------------------------------------------------|:----------|:---------|
| [insecureSkipVerify](#speckubernetesadvancedcontainerdregistryconfigsinsecureskipverify) | `boolean` | Optional |
| [password](#speckubernetesadvancedcontainerdregistryconfigspassword)                     | `string`  | Optional |
| [registry](#speckubernetesadvancedcontainerdregistryconfigsregistry)                     | `string`  | Required |
| [username](#speckubernetesadvancedcontainerdregistryconfigsusername)                     | `string`  | Optional |

## .spec.kubernetes.advanced.containerd.registryConfigs.insecureSkipVerify

### Description

Skip TLS verification for this registry.

## .spec.kubernetes.advanced.containerd.registryConfigs.password

### Description

Registry password.

## .spec.kubernetes.advanced.containerd.registryConfigs.registry

### Description

Registry hostname and optional path. Example: registry.example.com, registry.example.com:5000/myrepo

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^([a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,}(:[0-9]{1,5})?(/[a-z0-9._-]+)*$
```

[try pattern](https://regexr.com/?expression=^\([a-z0-9]\([a-z0-9-]{0,61}[a-z0-9]\)?\.\)%2B[a-z]{2,}\(:[0-9]{1,5}\)?\(\/[a-z0-9._-]%2B\)*$)

## .spec.kubernetes.advanced.containerd.registryConfigs.username

### Description

Registry username.

## .spec.kubernetes.advanced.encryption

### Properties

| Property                                                                          | Type     | Required |
|:----------------------------------------------------------------------------------|:---------|:---------|
| [configuration](#speckubernetesadvancedencryptionconfiguration)                   | `string` | Optional |
| [tlsCipherSuites](#speckubernetesadvancedencryptiontlsciphersuites)               | `array`  | Optional |
| [tlsCipherSuitesKubelet](#speckubernetesadvancedencryptiontlsciphersuiteskubelet) | `array`  | Optional |

### Description

Encryption at rest configuration. Ref: https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/

## .spec.kubernetes.advanced.encryption.configuration

### Description

EncryptionConfiguration YAML content (must be valid YAML with proper structure).

### Constraints

**minimum length**: the minimum number of characters for this string is: `50`

## .spec.kubernetes.advanced.encryption.tlsCipherSuites

### Description

TLS cipher suite name (IANA format). Example: TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^TLS_(ECDHE|RSA|DHE)_(ECDSA|RSA|PSK)_WITH_(AES|CHACHA20)_(128|256)_(GCM|CBC|POLY1305)_(SHA256|SHA384)$
```

[try pattern](https://regexr.com/?expression=^TLS_\(ECDHE|RSA|DHE\)_\(ECDSA|RSA|PSK\)_WITH_\(AES|CHACHA20\)_\(128|256\)_\(GCM|CBC|POLY1305\)_\(SHA256|SHA384\)$)

## .spec.kubernetes.advanced.encryption.tlsCipherSuitesKubelet

### Description

TLS cipher suite name (IANA format). Example: TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^TLS_(ECDHE|RSA|DHE)_(ECDSA|RSA|PSK)_WITH_(AES|CHACHA20)_(128|256)_(GCM|CBC|POLY1305)_(SHA256|SHA384)$
```

[try pattern](https://regexr.com/?expression=^TLS_\(ECDHE|RSA|DHE\)_\(ECDSA|RSA|PSK\)_WITH_\(AES|CHACHA20\)_\(128|256\)_\(GCM|CBC|POLY1305\)_\(SHA256|SHA384\)$)

## .spec.kubernetes.advanced.kubeletConfiguration

### Properties

| Property                                                                | Type      | Required |
|:------------------------------------------------------------------------|:----------|:---------|
| [maxPods](#speckubernetesadvancedkubeletconfigurationmaxpods)           | `integer` | Optional |
| [podPidsLimit](#speckubernetesadvancedkubeletconfigurationpodpidslimit) | `integer` | Optional |

### Description

Kubelet configuration parameters. Ref: https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/

## .spec.kubernetes.advanced.kubeletConfiguration.maxPods

### Description

Maximum number of pods per node. Example: 200

## .spec.kubernetes.advanced.kubeletConfiguration.podPidsLimit

### Description

Maximum number of PIDs per pod. Example: 8192

## .spec.kubernetes.advanced.oidc

### Properties

| Property                                                      | Type     | Required |
|:--------------------------------------------------------------|:---------|:---------|
| [client_id](#speckubernetesadvancedoidcclient_id)             | `string` | Optional |
| [groups_claim](#speckubernetesadvancedoidcgroups_claim)       | `string` | Optional |
| [groups_prefix](#speckubernetesadvancedoidcgroups_prefix)     | `string` | Optional |
| [issuer_url](#speckubernetesadvancedoidcissuer_url)           | `string` | Optional |
| [username_claim](#speckubernetesadvancedoidcusername_claim)   | `string` | Optional |
| [username_prefix](#speckubernetesadvancedoidcusername_prefix) | `string` | Optional |

### Description

OIDC authentication provider configuration. Ref: https://kubernetes.io/docs/reference/access-authn-authz/authentication/#openid-connect-tokens

## .spec.kubernetes.advanced.oidc.client_id

### Description

OIDC client ID.

## .spec.kubernetes.advanced.oidc.groups_claim

### Description

OIDC groups claim.

## .spec.kubernetes.advanced.oidc.groups_prefix

### Description

Prefix for OIDC groups.

## .spec.kubernetes.advanced.oidc.issuer_url

### Description

OIDC issuer URL.

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^(http|https)\:\/\/.+$
```

[try pattern](https://regexr.com/?expression=^\(http|https\)\:\\/\\/.%2B$)

## .spec.kubernetes.advanced.oidc.username_claim

### Description

OIDC username claim.

## .spec.kubernetes.advanced.oidc.username_prefix

### Description

Prefix for OIDC usernames.

## .spec.kubernetes.advanced.users

### Properties

| Property                                   | Type     | Required |
|:-------------------------------------------|:---------|:---------|
| [names](#speckubernetesadvancedusersnames) | `array`  | Optional |
| [org](#speckubernetesadvancedusersorg)     | `string` | Optional |

### Description

User certificate generation configuration.

## .spec.kubernetes.advanced.users.names

### Description

List of user names for certificate generation.

## .spec.kubernetes.advanced.users.org

### Description

Organization name for user certificates.

## .spec.kubernetes.controlPlane

### Properties

| Property                                                                | Type     | Required |
|:------------------------------------------------------------------------|:---------|:---------|
| [address](#speckubernetescontrolplaneaddress)                           | `string` | Required |
| [kubeletConfiguration](#speckubernetescontrolplanekubeletconfiguration) | `object` | Optional |
| [members](#speckubernetescontrolplanemembers)                           | `array`  | Required |

### Description

Control plane configuration.

## .spec.kubernetes.controlPlane.address

### Description

The address for the Kubernetes control plane with port. Example: k8s-api.example.com:6443

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[a-zA-Z0-9.-]+:[0-9]+$
```

[try pattern](https://regexr.com/?expression=^[a-zA-Z0-9.-]%2B:[0-9]%2B$)

## .spec.kubernetes.controlPlane.kubeletConfiguration

### Properties

| Property                                                                    | Type      | Required |
|:----------------------------------------------------------------------------|:----------|:---------|
| [maxPods](#speckubernetescontrolplanekubeletconfigurationmaxpods)           | `integer` | Optional |
| [podPidsLimit](#speckubernetescontrolplanekubeletconfigurationpodpidslimit) | `integer` | Optional |

### Description

Kubelet configuration parameters. Ref: https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/

## .spec.kubernetes.controlPlane.kubeletConfiguration.maxPods

### Description

Maximum number of pods per node. Example: 200

## .spec.kubernetes.controlPlane.kubeletConfiguration.podPidsLimit

### Description

Maximum number of PIDs per pod. Example: 8192

## .spec.kubernetes.controlPlane.members

### Properties

| Property                                               | Type     | Required |
|:-------------------------------------------------------|:---------|:---------|
| [hostname](#speckubernetescontrolplanemembershostname) | `string` | Required |
| [ip](#speckubernetescontrolplanemembersip)             | `string` | Optional |

### Description

A member node reference with optional IP override.

### Constraints

**minimum number of items**: the minimum number of items for this array is: `1`

## .spec.kubernetes.controlPlane.members.hostname

### Description

Hostname that must match an infrastructure node. Example: ctrl01.k8s.example.com

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.kubernetes.controlPlane.members.ip

### Description

Optional IP address. If not specified, it is inferred from the node's network configuration.

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.){3}(25[0-5]|(2[0-4]|1\d|[1-9]|)\d)$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.\){3}\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)$)

## .spec.kubernetes.etcd

### Properties

| Property                              | Type    | Required |
|:--------------------------------------|:--------|:---------|
| [members](#speckubernetesetcdmembers) | `array` | Required |

### Description

etcd cluster configuration. Ref: https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/

## .spec.kubernetes.etcd.members

### Properties

| Property                                       | Type     | Required |
|:-----------------------------------------------|:---------|:---------|
| [hostname](#speckubernetesetcdmembershostname) | `string` | Required |
| [ip](#speckubernetesetcdmembersip)             | `string` | Optional |

### Description

A member node reference with optional IP override.

### Constraints

**minimum number of items**: the minimum number of items for this array is: `1`

## .spec.kubernetes.etcd.members.hostname

### Description

Hostname that must match an infrastructure node. Example: ctrl01.k8s.example.com

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.kubernetes.etcd.members.ip

### Description

Optional IP address. If not specified, it is inferred from the node's network configuration.

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.){3}(25[0-5]|(2[0-4]|1\d|[1-9]|)\d)$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.\){3}\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)$)

## .spec.kubernetes.loadBalancers

### Properties

| Property                                           | Type      | Required |
|:---------------------------------------------------|:----------|:---------|
| [enabled](#speckubernetesloadbalancersenabled)     | `boolean` | Optional |
| [members](#speckubernetesloadbalancersmembers)     | `array`   | Required |
| [virtualIP](#speckubernetesloadbalancersvirtualip) | `string`  | Required |

### Description

Load balancer configuration for high-availability API server access. Uses HAProxy for load balancing and keepalived for VIP failover.

## .spec.kubernetes.loadBalancers.enabled

### Description

Enable load balancer configuration. When true, HAProxy and keepalived will be configured.

## .spec.kubernetes.loadBalancers.members

### Properties

| Property                                                | Type     | Required |
|:--------------------------------------------------------|:---------|:---------|
| [hostname](#speckubernetesloadbalancersmembershostname) | `string` | Required |
| [ip](#speckubernetesloadbalancersmembersip)             | `string` | Optional |

### Description

A member node reference with optional IP override.

### Constraints

**minimum number of items**: the minimum number of items for this array is: `1`

## .spec.kubernetes.loadBalancers.members.hostname

### Description

Hostname that must match an infrastructure node. Example: ctrl01.k8s.example.com

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.kubernetes.loadBalancers.members.ip

### Description

Optional IP address. If not specified, it is inferred from the node's network configuration.

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.){3}(25[0-5]|(2[0-4]|1\d|[1-9]|)\d)$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.\){3}\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)$)

## .spec.kubernetes.loadBalancers.virtualIP

### Description

Virtual IP address managed by keepalived for HA. This IP will be used as the control plane address. Example: 192.168.1.10

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.){3}(25[0-5]|(2[0-4]|1\d|[1-9]|)\d)$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.\){3}\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)$)

## .spec.kubernetes.networking

### Properties

| Property                                            | Type     | Required |
|:----------------------------------------------------|:---------|:---------|
| [podCIDR](#speckubernetesnetworkingpodcidr)         | `string` | Required |
| [serviceCIDR](#speckubernetesnetworkingservicecidr) | `string` | Required |

### Description

Kubernetes network configuration. Ref: https://kubernetes.io/docs/concepts/cluster-administration/networking/

## .spec.kubernetes.networking.podCIDR

### Description

Pod network CIDR. Example: 10.244.0.0/16

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.){3}(25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\/(3[0-2]|[1-2][0-9]|[0-9])$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.\){3}\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\\/\(3[0-2]|[1-2][0-9]|[0-9]\)$)

## .spec.kubernetes.networking.serviceCIDR

### Description

Service network CIDR. Example: 10.96.0.0/12

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.){3}(25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\/(3[0-2]|[1-2][0-9]|[0-9])$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.\){3}\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\\/\(3[0-2]|[1-2][0-9]|[0-9]\)$)

## .spec.kubernetes.nodeGroups

### Properties

| Property                                                              | Type     | Required |
|:----------------------------------------------------------------------|:---------|:---------|
| [annotations](#speckubernetesnodegroupsannotations)                   | `object` | Optional |
| [kubeletConfiguration](#speckubernetesnodegroupskubeletconfiguration) | `object` | Optional |
| [labels](#speckubernetesnodegroupslabels)                             | `object` | Optional |
| [name](#speckubernetesnodegroupsname)                                 | `string` | Required |
| [nodes](#speckubernetesnodegroupsnodes)                               | `array`  | Required |
| [taints](#speckubernetesnodegroupstaints)                             | `array`  | Optional |

### Description

A group of worker nodes with common labels, taints, and annotations. Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/

## .spec.kubernetes.nodeGroups.annotations

### Description

Kubernetes annotations to apply to nodes in this group.

## .spec.kubernetes.nodeGroups.kubeletConfiguration

### Properties

| Property                                                                  | Type      | Required |
|:--------------------------------------------------------------------------|:----------|:---------|
| [maxPods](#speckubernetesnodegroupskubeletconfigurationmaxpods)           | `integer` | Optional |
| [podPidsLimit](#speckubernetesnodegroupskubeletconfigurationpodpidslimit) | `integer` | Optional |

### Description

Kubelet configuration parameters. Ref: https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/

## .spec.kubernetes.nodeGroups.kubeletConfiguration.maxPods

### Description

Maximum number of pods per node. Example: 200

## .spec.kubernetes.nodeGroups.kubeletConfiguration.podPidsLimit

### Description

Maximum number of PIDs per pod. Example: 8192

## .spec.kubernetes.nodeGroups.labels

### Description

Kubernetes labels to apply to nodes in this group.

## .spec.kubernetes.nodeGroups.name

### Description

Node group name identifier. Example: infra_workers

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.kubernetes.nodeGroups.nodes

### Properties

| Property                                           | Type     | Required |
|:---------------------------------------------------|:---------|:---------|
| [hostname](#speckubernetesnodegroupsnodeshostname) | `string` | Required |
| [ip](#speckubernetesnodegroupsnodesip)             | `string` | Optional |

### Description

A member node reference with optional IP override.

### Constraints

**minimum number of items**: the minimum number of items for this array is: `1`

## .spec.kubernetes.nodeGroups.nodes.hostname

### Description

Hostname that must match an infrastructure node. Example: ctrl01.k8s.example.com

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.kubernetes.nodeGroups.nodes.ip

### Description

Optional IP address. If not specified, it is inferred from the node's network configuration.

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.){3}(25[0-5]|(2[0-4]|1\d|[1-9]|)\d)$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.\){3}\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)$)

## .spec.kubernetes.nodeGroups.taints

### Properties

| Property                                        | Type     | Required |
|:------------------------------------------------|:---------|:---------|
| [effect](#speckubernetesnodegroupstaintseffect) | `string` | Required |
| [key](#speckubernetesnodegroupstaintskey)       | `string` | Required |
| [value](#speckubernetesnodegroupstaintsvalue)   | `string` | Required |

### Description

Kubernetes taints to apply to nodes in this group.

## .spec.kubernetes.nodeGroups.taints.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.kubernetes.nodeGroups.taints.key

## .spec.kubernetes.nodeGroups.taints.value

## .spec.kubernetes.version

### Description

Kubernetes version for sysext packages. Determines versions of containerd, kubernetes, and other components from installer defaults. Example: 1.33.4

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^\d+\.\d+\.\d+$
```

[try pattern](https://regexr.com/?expression=^\d%2B\.\d%2B\.\d%2B$)

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

