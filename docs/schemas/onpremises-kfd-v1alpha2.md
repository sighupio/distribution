# OnPremises - SD On Premises Cluster Schema

This document explains the full schema for the `kind: OnPremises` for the `furyctl.yaml` file used by `furyctl`. This configuration file will be used to deploy the SIGHUP Distribution modules and cluster on premises.

An example configuration file can be created by running the following command:

```bash
furyctl create config --kind OnPremises --version v1.29.4 --name example-cluster
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

A KFD Cluster deployed on top of a set of existing VMs.

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

| Value        |
|:-------------|
|`"OnPremises"`|

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
| [kubernetes](#speckubernetes)                   | `object` | Optional |
| [plugins](#specplugins)                         | `object` | Optional |

## .spec.distribution

### Properties

| Property                                        | Type     | Required |
|:------------------------------------------------|:---------|:---------|
| [common](#specdistributioncommon)               | `object` | Optional |
| [customPatches](#specdistributioncustompatches) | `object` | Optional |
| [modules](#specdistributionmodules)             | `object` | Required |

## .spec.distribution.common

### Properties

| Property                                                                | Type      | Required |
|:------------------------------------------------------------------------|:----------|:---------|
| [networkPoliciesEnabled](#specdistributioncommonnetworkpoliciesenabled) | `boolean` | Optional |
| [nodeSelector](#specdistributioncommonnodeselector)                     | `object`  | Optional |
| [provider](#specdistributioncommonprovider)                             | `object`  | Optional |
| [registry](#specdistributioncommonregistry)                             | `string`  | Optional |
| [relativeVendorPath](#specdistributioncommonrelativevendorpath)         | `string`  | Optional |
| [tolerations](#specdistributioncommontolerations)                       | `array`   | Optional |

### Description

Common configuration for all the distribution modules.

## .spec.distribution.common.networkPoliciesEnabled

### Description

EXPERIMENTAL FEATURE. This field defines whether Network Policies are provided for core modules.

## .spec.distribution.common.nodeSelector

### Description

The node selector to use to place the pods for all the KFD modules. Follows Kubernetes selector format. Example: `node.kubernetes.io/role: infra`.

## .spec.distribution.common.provider

### Properties

| Property                                    | Type     | Required |
|:--------------------------------------------|:---------|:---------|
| [type](#specdistributioncommonprovidertype) | `string` | Required |

## .spec.distribution.common.provider.type

### Description

The provider type. Don't set. FOR INTERNAL USE ONLY.

## .spec.distribution.common.registry

### Description

URL of the registry where to pull images from for the Distribution phase. (Default is `registry.sighup.io/fury`).

NOTE: If plugins are pulling from the default registry, the registry will be replaced for the plugin too.

## .spec.distribution.common.relativeVendorPath

### Description

The relative path to the vendor directory, does not need to be changed.

## .spec.distribution.common.tolerations

### Properties

| Property                                               | Type     | Required |
|:-------------------------------------------------------|:---------|:---------|
| [effect](#specdistributioncommontolerationseffect)     | `string` | Required |
| [key](#specdistributioncommontolerationskey)           | `string` | Required |
| [operator](#specdistributioncommontolerationsoperator) | `string` | Optional |
| [value](#specdistributioncommontolerationsvalue)       | `string` | Optional |

### Description

An array with the tolerations that will be added to the pods for all the KFD modules. Follows Kubernetes tolerations format. Example:

```yaml
- effect: NoSchedule
  key: node.kubernetes.io/role
  value: infra
```

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
| [auth](#specdistributionmodulesauth)             | `object` | Optional |
| [dr](#specdistributionmodulesdr)                 | `object` | Required |
| [ingress](#specdistributionmodulesingress)       | `object` | Required |
| [logging](#specdistributionmoduleslogging)       | `object` | Required |
| [monitoring](#specdistributionmodulesmonitoring) | `object` | Optional |
| [networking](#specdistributionmodulesnetworking) | `object` | Optional |
| [policy](#specdistributionmodulespolicy)         | `object` | Required |
| [tracing](#specdistributionmodulestracing)       | `object` | Optional |

## .spec.distribution.modules.auth

### Properties

| Property                                                             | Type     | Required |
|:---------------------------------------------------------------------|:---------|:---------|
| [baseDomain](#specdistributionmodulesauthbasedomain)                 | `string` | Optional |
| [dex](#specdistributionmodulesauthdex)                               | `object` | Optional |
| [oidcKubernetesAuth](#specdistributionmodulesauthoidckubernetesauth) | `object` | Optional |
| [oidcTrustedCA](#specdistributionmodulesauthoidctrustedca)           | `string` | Optional |
| [overrides](#specdistributionmodulesauthoverrides)                   | `object` | Optional |
| [pomerium](#specdistributionmodulesauthpomerium)                     | `object` | Optional |
| [provider](#specdistributionmodulesauthprovider)                     | `object` | Required |

### Description

Configuration for the Auth module.

## .spec.distribution.modules.auth.baseDomain

### Description

The base domain for the ingresses created by the Auth module (Gangplank, Pomerium, Dex). Notice that when the ingress module type is `dual`, these will use the `external` ingress class.

## .spec.distribution.modules.auth.dex

### Properties

| Property                                                                          | Type     | Required |
|:----------------------------------------------------------------------------------|:---------|:---------|
| [additionalStaticClients](#specdistributionmodulesauthdexadditionalstaticclients) | `array`  | Optional |
| [connectors](#specdistributionmodulesauthdexconnectors)                           | `array`  | Required |
| [expiry](#specdistributionmodulesauthdexexpiry)                                   | `object` | Optional |
| [overrides](#specdistributionmodulesauthdexoverrides)                             | `object` | Optional |

### Description

Configuration for the Dex package.

## .spec.distribution.modules.auth.dex.additionalStaticClients

### Description

Additional static clients defitions that will be added to the default clients included with the distribution in Dex's configuration. Example:

```yaml
additionalStaticClients:
  - id: my-custom-client
    name: "A custom additional static client"
    redirectURIs:
      - "https://myapp.tld/redirect"
      - "https://alias.tld/oidc-callback"
    secret: supersecretpassword
```
Reference: https://dexidp.io/docs/connectors/local/

## .spec.distribution.modules.auth.dex.connectors

### Description

A list with each item defining a Dex connector. Follows Dex connectors configuration format: https://dexidp.io/docs/connectors/

## .spec.distribution.modules.auth.dex.expiry

### Properties

| Property                                                        | Type     | Required |
|:----------------------------------------------------------------|:---------|:---------|
| [idTokens](#specdistributionmodulesauthdexexpiryidtokens)       | `string` | Optional |
| [signingKeys](#specdistributionmodulesauthdexexpirysigningkeys) | `string` | Optional |

## .spec.distribution.modules.auth.dex.expiry.idTokens

### Description

Dex ID tokens expiration time duration (default 24h).

## .spec.distribution.modules.auth.dex.expiry.signingKeys

### Description

Dex signing key expiration time duration (default 6h).

## .spec.distribution.modules.auth.dex.overrides

### Properties

| Property                                                             | Type     | Required |
|:---------------------------------------------------------------------|:---------|:---------|
| [nodeSelector](#specdistributionmodulesauthdexoverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulesauthdexoverridestolerations)   | `array`  | Optional |

## .spec.distribution.modules.auth.dex.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the package.

## .spec.distribution.modules.auth.dex.overrides.tolerations

### Properties

| Property                                                                | Type     | Required |
|:------------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulesauthdexoverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulesauthdexoverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulesauthdexoverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulesauthdexoverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the package.

## .spec.distribution.modules.auth.dex.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.auth.dex.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.auth.dex.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.auth.dex.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.auth.oidcKubernetesAuth

### Properties

| Property                                                                                       | Type      | Required |
|:-----------------------------------------------------------------------------------------------|:----------|:---------|
| [clientID](#specdistributionmodulesauthoidckubernetesauthclientid)                             | `string`  | Optional |
| [clientSecret](#specdistributionmodulesauthoidckubernetesauthclientsecret)                     | `string`  | Optional |
| [emailClaim](#specdistributionmodulesauthoidckubernetesauthemailclaim)                         | `string`  | Optional |
| [enabled](#specdistributionmodulesauthoidckubernetesauthenabled)                               | `boolean` | Required |
| [namespace](#specdistributionmodulesauthoidckubernetesauthnamespace)                           | `string`  | Optional |
| [removeCAFromKubeconfig](#specdistributionmodulesauthoidckubernetesauthremovecafromkubeconfig) | `boolean` | Optional |
| [scopes](#specdistributionmodulesauthoidckubernetesauthscopes)                                 | `array`   | Optional |
| [sessionSecurityKey](#specdistributionmodulesauthoidckubernetesauthsessionsecuritykey)         | `string`  | Optional |
| [usernameClaim](#specdistributionmodulesauthoidckubernetesauthusernameclaim)                   | `string`  | Optional |

## .spec.distribution.modules.auth.oidcKubernetesAuth.clientID

### Description

The client ID that the Kubernetes API will use to authenticate against the OIDC provider (Dex).

## .spec.distribution.modules.auth.oidcKubernetesAuth.clientSecret

### Description

The client secret that the Kubernetes API will use to authenticate against the OIDC provider (Dex).

## .spec.distribution.modules.auth.oidcKubernetesAuth.emailClaim

### Description

DEPRECATED. Defaults to `email`.

## .spec.distribution.modules.auth.oidcKubernetesAuth.enabled

### Description

If true, components needed for interacting with the Kubernetes API with OIDC authentication (Gangplank, Dex) be deployed and configued.

## .spec.distribution.modules.auth.oidcKubernetesAuth.namespace

### Description

The namespace to set in the context of the kubeconfig file generated by Gangplank. Defaults to `default`.

## .spec.distribution.modules.auth.oidcKubernetesAuth.removeCAFromKubeconfig

### Description

Set to true to remove the CA from the kubeconfig file generated by Gangplank.

## .spec.distribution.modules.auth.oidcKubernetesAuth.scopes

### Description

Used to specify the scope of the requested Oauth authorization by Gangplank. Defaults to: `["openid", "profile", "email", "offline_access", "groups"]`

## .spec.distribution.modules.auth.oidcKubernetesAuth.sessionSecurityKey

### Description

The Key to use for the sessions in Gangplank. Must be different between different instances of Gangplank.

## .spec.distribution.modules.auth.oidcKubernetesAuth.usernameClaim

### Description

The JWT claim to use as the username. This is used in Gangplank's UI. This is combined with the clusterName for the user portion of the kubeconfig. Defaults to `nickname`.

## .spec.distribution.modules.auth.oidcTrustedCA

### Description

The Certificate Authority certificate file's content to trust for self-signed certificates at the OAuth2 URL. You can use the `"{file://<path>}"` notation to get the content from a file.

## .spec.distribution.modules.auth.overrides

### Properties

| Property                                                          | Type     | Required |
|:------------------------------------------------------------------|:---------|:---------|
| [ingresses](#specdistributionmodulesauthoverridesingresses)       | `object` | Optional |
| [nodeSelector](#specdistributionmodulesauthoverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulesauthoverridestolerations)   | `array`  | Optional |

### Description

Override the common configuration with a particular configuration for the Auth module.

## .spec.distribution.modules.auth.overrides.ingresses

### Properties

| Property                                                             | Type     | Required |
|:---------------------------------------------------------------------|:---------|:---------|
| [dex](#specdistributionmodulesauthoverridesingressesdex)             | `object` | Optional |
| [gangplank](#specdistributionmodulesauthoverridesingressesgangplank) | `object` | Optional |

### Description

Override the definition of the Auth module ingresses.

## .spec.distribution.modules.auth.overrides.ingresses.dex

### Properties

| Property                                                                      | Type     | Required |
|:------------------------------------------------------------------------------|:---------|:---------|
| [host](#specdistributionmodulesauthoverridesingressesdexhost)                 | `string` | Required |
| [ingressClass](#specdistributionmodulesauthoverridesingressesdexingressclass) | `string` | Required |

## .spec.distribution.modules.auth.overrides.ingresses.dex.host

### Description

Use this host for the ingress instead of the default one.

## .spec.distribution.modules.auth.overrides.ingresses.dex.ingressClass

### Description

Use this ingress class for the ingress instead of the default one.

## .spec.distribution.modules.auth.overrides.ingresses.gangplank

### Properties

| Property                                                                            | Type     | Required |
|:------------------------------------------------------------------------------------|:---------|:---------|
| [host](#specdistributionmodulesauthoverridesingressesgangplankhost)                 | `string` | Required |
| [ingressClass](#specdistributionmodulesauthoverridesingressesgangplankingressclass) | `string` | Required |

## .spec.distribution.modules.auth.overrides.ingresses.gangplank.host

### Description

Use this host for the ingress instead of the default one.

## .spec.distribution.modules.auth.overrides.ingresses.gangplank.ingressClass

### Description

Use this ingress class for the ingress instead of the default one.

## .spec.distribution.modules.auth.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the Auth module.

## .spec.distribution.modules.auth.overrides.tolerations

### Properties

| Property                                                             | Type     | Required |
|:---------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulesauthoverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulesauthoverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulesauthoverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulesauthoverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the Auth module.

## .spec.distribution.modules.auth.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.auth.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.auth.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.auth.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.auth.pomerium

### Properties

| Property                                                                       | Type     | Required |
|:-------------------------------------------------------------------------------|:---------|:---------|
| [defaultRoutesPolicy](#specdistributionmodulesauthpomeriumdefaultroutespolicy) | `object` | Optional |
| [overrides](#specdistributionmodulesauthpomeriumoverrides)                     | `object` | Optional |
| [policy](#specdistributionmodulesauthpomeriumpolicy)                           | `string` | Optional |
| [routes](#specdistributionmodulesauthpomeriumroutes)                           | `array`  | Optional |
| [secrets](#specdistributionmodulesauthpomeriumsecrets)                         | `object` | Required |

### Description

Configuration for Pomerium, an identity-aware reverse proxy used for SSO.

## .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy

### Properties

| Property                                                                                                          | Type    | Required |
|:------------------------------------------------------------------------------------------------------------------|:--------|:---------|
| [gatekeeperPolicyManager](#specdistributionmodulesauthpomeriumdefaultroutespolicygatekeeperpolicymanager)         | `array` | Optional |
| [hubbleUi](#specdistributionmodulesauthpomeriumdefaultroutespolicyhubbleui)                                       | `array` | Optional |
| [ingressNgnixForecastle](#specdistributionmodulesauthpomeriumdefaultroutespolicyingressngnixforecastle)           | `array` | Optional |
| [loggingMinioConsole](#specdistributionmodulesauthpomeriumdefaultroutespolicyloggingminioconsole)                 | `array` | Optional |
| [loggingOpensearchDashboards](#specdistributionmodulesauthpomeriumdefaultroutespolicyloggingopensearchdashboards) | `array` | Optional |
| [monitoringAlertmanager](#specdistributionmodulesauthpomeriumdefaultroutespolicymonitoringalertmanager)           | `array` | Optional |
| [monitoringGrafana](#specdistributionmodulesauthpomeriumdefaultroutespolicymonitoringgrafana)                     | `array` | Optional |
| [monitoringMinioConsole](#specdistributionmodulesauthpomeriumdefaultroutespolicymonitoringminioconsole)           | `array` | Optional |
| [monitoringPrometheus](#specdistributionmodulesauthpomeriumdefaultroutespolicymonitoringprometheus)               | `array` | Optional |
| [tracingMinioConsole](#specdistributionmodulesauthpomeriumdefaultroutespolicytracingminioconsole)                 | `array` | Optional |

### Description

override default routes for KFD components

## .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.gatekeeperPolicyManager

## .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.hubbleUi

## .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.ingressNgnixForecastle

## .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.loggingMinioConsole

## .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.loggingOpensearchDashboards

## .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.monitoringAlertmanager

## .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.monitoringGrafana

## .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.monitoringMinioConsole

## .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.monitoringPrometheus

## .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.tracingMinioConsole

## .spec.distribution.modules.auth.pomerium.overrides

### Properties

| Property                                                                  | Type     | Required |
|:--------------------------------------------------------------------------|:---------|:---------|
| [nodeSelector](#specdistributionmodulesauthpomeriumoverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulesauthpomeriumoverridestolerations)   | `array`  | Optional |

## .spec.distribution.modules.auth.pomerium.overrides.nodeSelector

## .spec.distribution.modules.auth.pomerium.overrides.tolerations

### Properties

| Property                                                                     | Type     | Required |
|:-----------------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulesauthpomeriumoverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulesauthpomeriumoverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulesauthpomeriumoverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulesauthpomeriumoverridestolerationsvalue)       | `string` | Required |

## .spec.distribution.modules.auth.pomerium.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.auth.pomerium.overrides.tolerations.key

## .spec.distribution.modules.auth.pomerium.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.auth.pomerium.overrides.tolerations.value

## .spec.distribution.modules.auth.pomerium.policy

### Description

DEPRECATED: Use defaultRoutesPolicy and/or routes

## .spec.distribution.modules.auth.pomerium.routes

### Description

Additional routes configuration for Pomerium. Follows Pomerium's route format: https://www.pomerium.com/docs/reference/routes

## .spec.distribution.modules.auth.pomerium.secrets

### Properties

| Property                                                                          | Type     | Required |
|:----------------------------------------------------------------------------------|:---------|:---------|
| [COOKIE_SECRET](#specdistributionmodulesauthpomeriumsecretscookie_secret)         | `string` | Required |
| [IDP_CLIENT_SECRET](#specdistributionmodulesauthpomeriumsecretsidp_client_secret) | `string` | Required |
| [SHARED_SECRET](#specdistributionmodulesauthpomeriumsecretsshared_secret)         | `string` | Required |
| [SIGNING_KEY](#specdistributionmodulesauthpomeriumsecretssigning_key)             | `string` | Required |

### Description

Pomerium needs some user-provided secrets to be fully configured. These secrets should be unique between clusters.

## .spec.distribution.modules.auth.pomerium.secrets.COOKIE_SECRET

### Description

Cookie Secret is the secret used to encrypt and sign session cookies.

To generate a random key, run the following command: `head -c32 /dev/urandom | base64`

## .spec.distribution.modules.auth.pomerium.secrets.IDP_CLIENT_SECRET

### Description

Identity Provider Client Secret is the OAuth 2.0 Secret Identifier. When auth type is SSO, this value will be the secret used to authenticate Pomerium with Dex, **use a strong random value**.

## .spec.distribution.modules.auth.pomerium.secrets.SHARED_SECRET

### Description

Shared Secret is the base64-encoded, 256-bit key used to mutually authenticate requests between Pomerium services. It's critical that secret keys are random, and stored safely.

To generate a key, run the following command: `head -c32 /dev/urandom | base64`

## .spec.distribution.modules.auth.pomerium.secrets.SIGNING_KEY

### Description

Signing Key is the base64 representation of one or more PEM-encoded private keys used to sign a user's attestation JWT, which can be consumed by upstream applications to pass along identifying user information like username, id, and groups.

To generates an P-256 (ES256) signing key:

```bash
openssl ecparam  -genkey  -name prime256v1  -noout  -out ec_private.pem
# careful! this will output your private key in terminal
cat ec_private.pem | base64
```

## .spec.distribution.modules.auth.provider

### Properties

| Property                                                   | Type     | Required |
|:-----------------------------------------------------------|:---------|:---------|
| [basicAuth](#specdistributionmodulesauthproviderbasicauth) | `object` | Optional |
| [type](#specdistributionmodulesauthprovidertype)           | `string` | Required |

## .spec.distribution.modules.auth.provider.basicAuth

### Properties

| Property                                                          | Type     | Required |
|:------------------------------------------------------------------|:---------|:---------|
| [password](#specdistributionmodulesauthproviderbasicauthpassword) | `string` | Required |
| [username](#specdistributionmodulesauthproviderbasicauthusername) | `string` | Required |

### Description

Configuration for the HTTP Basic Auth provider.

## .spec.distribution.modules.auth.provider.basicAuth.password

### Description

The password for logging in with the HTTP basic authentication.

## .spec.distribution.modules.auth.provider.basicAuth.username

### Description

The username for logging in with the HTTP basic authentication.

## .spec.distribution.modules.auth.provider.type

### Description

The type of the Auth provider, options are:
- `none`: will disable authentication in the infrastructural ingresses.
- `sso`: will protect the infrastructural ingresses with Pomerium and Dex (SSO) and require authentication before accessing them.
- `basicAuth`: will protect the infrastructural ingresses with HTTP basic auth (username and password) authentication.

Default is `none`.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value       |
|:------------|
|`"none"`     |
|`"basicAuth"`|
|`"sso"`      |

## .spec.distribution.modules.dr

### Properties

| Property                                           | Type     | Required |
|:---------------------------------------------------|:---------|:---------|
| [etcdBackup](#specdistributionmodulesdretcdbackup) | `object` | Optional |
| [overrides](#specdistributionmodulesdroverrides)   | `object` | Optional |
| [type](#specdistributionmodulesdrtype)             | `string` | Required |
| [velero](#specdistributionmodulesdrvelero)         | `object` | Optional |

### Description

Configuration for the Disaster Recovery module.

## .spec.distribution.modules.dr.etcdBackup

### Properties

| Property                                                         | Type     | Required |
|:-----------------------------------------------------------------|:---------|:---------|
| [backupPrefix](#specdistributionmodulesdretcdbackupbackupprefix) | `string` | Optional |
| [pvc](#specdistributionmodulesdretcdbackuppvc)                   | `object` | Optional |
| [s3](#specdistributionmodulesdretcdbackups3)                     | `object` | Optional |
| [type](#specdistributionmodulesdretcdbackuptype)                 | `string` | Optional |

### Description

Configuration for the ETCD backup package.

## .spec.distribution.modules.dr.etcdBackup.backupPrefix

### Description

A prefix to be prepended to the backup filenames. If unset, the prefix defaults to the cluster's name.

## .spec.distribution.modules.dr.etcdBackup.pvc

### Properties

| Property                                                              | Type     | Required |
|:----------------------------------------------------------------------|:---------|:---------|
| [accessModes](#specdistributionmodulesdretcdbackuppvcaccessmodes)     | `array`  | Optional |
| [name](#specdistributionmodulesdretcdbackuppvcname)                   | `string` | Optional |
| [retentionTime](#specdistributionmodulesdretcdbackuppvcretentiontime) | `string` | Optional |
| [schedule](#specdistributionmodulesdretcdbackuppvcschedule)           | `string` | Optional |
| [size](#specdistributionmodulesdretcdbackuppvcsize)                   | `string` | Optional |
| [storageClass](#specdistributionmodulesdretcdbackuppvcstorageclass)   | `string` | Optional |

### Description

Configuration parameters for the `pvc` type of `etcdBackup`.

## .spec.distribution.modules.dr.etcdBackup.pvc.accessModes

### Description

The accessModes that the `furyctl`-managed PersistentVolumeClaim will use. This has no effect and is ignored if `name` is set. Default is `["ReadOnlyOnce"]`

## .spec.distribution.modules.dr.etcdBackup.pvc.name

### Description

The PersistentVolumeClaim name where the backups will be saved. If set, `size` and `storageClass` will be ignored and `etcd-backup` will use the PersistentVolumeClaim that matches the name set. Please note that the PersistentVolumeClaim must be created inside the `kube-system` namespace.

If you leave `name` unset `furyctl` will create a PersistentVolumeClaim for you with an arbitrary name.

## .spec.distribution.modules.dr.etcdBackup.pvc.retentionTime

### Description

The retention time of the backups inside the PersistentVolumeClaim. Follows rclone's `min-age` format. Example: '30d' for 30 days. Default is `10d` (ten days).

## .spec.distribution.modules.dr.etcdBackup.pvc.schedule

### Description

The cron expression for the `etcd-backup-pvc` backup schedule. Default is `0 1 * * *` (everyday at 01:00).

## .spec.distribution.modules.dr.etcdBackup.pvc.size

### Description

The size that the `furyctl`-managed PersistentVolumeClaim will use. This has no effect and is ignored if `name` is set. Default is `10G`.

## .spec.distribution.modules.dr.etcdBackup.pvc.storageClass

### Description

The storage class that the `furyctl`-managed PersistentVolumeClaim will use. This has no effect and is ignored if `name` is set. Default is `default`.

## .spec.distribution.modules.dr.etcdBackup.s3

### Properties

| Property                                                                 | Type      | Required |
|:-------------------------------------------------------------------------|:----------|:---------|
| [accessKeyId](#specdistributionmodulesdretcdbackups3accesskeyid)         | `string`  | Required |
| [bucketName](#specdistributionmodulesdretcdbackups3bucketname)           | `string`  | Required |
| [endpoint](#specdistributionmodulesdretcdbackups3endpoint)               | `string`  | Required |
| [insecure](#specdistributionmodulesdretcdbackups3insecure)               | `boolean` | Optional |
| [retentionTime](#specdistributionmodulesdretcdbackups3retentiontime)     | `string`  | Optional |
| [schedule](#specdistributionmodulesdretcdbackups3schedule)               | `string`  | Optional |
| [secretAccessKey](#specdistributionmodulesdretcdbackups3secretaccesskey) | `string`  | Required |

### Description

Configuration parameters for the `s3` type of `etcdBackup`.

## .spec.distribution.modules.dr.etcdBackup.s3.accessKeyId

### Description

The access key ID (username) for the external S3-compatible bucket.

## .spec.distribution.modules.dr.etcdBackup.s3.bucketName

### Description

The bucket name of the external S3-compatible object storage.

## .spec.distribution.modules.dr.etcdBackup.s3.endpoint

### Description

External S3-compatible endpoint for etcd-backup-s3's storage.

## .spec.distribution.modules.dr.etcdBackup.s3.insecure

### Description

If true, will use HTTP as protocol instead of HTTPS.

## .spec.distribution.modules.dr.etcdBackup.s3.retentionTime

### Description

The retention time of the external S3-compatible object storage. Follows rclone's `min-age` format. Example: '30d' for 30 days. Default is `10d` (ten days).

## .spec.distribution.modules.dr.etcdBackup.s3.schedule

### Description

The cron expression for the `etcd-backup-s3` backup schedule. Default is `0 1 * * *` (everyday at 01:00).

## .spec.distribution.modules.dr.etcdBackup.s3.secretAccessKey

### Description

The secret access key (password) for the external S3-compatible bucket.

## .spec.distribution.modules.dr.etcdBackup.type

### Description

The type of the etcd backup to enable, options are:
- `none`: no etcd backup CronJob will be installed and no etcd backup will be performed.
- `s3`: the etcd-backup-s3 package will be enabled. It will deploy a CronJob which continuously snapshots a healthy etcd node and will save the backups in a configured S3 bucket.
- `pvc`: the etcd-backup-pvc package will be enabled. It will deploy a CronJob which continuously snapshots a healthy etcd node and will save the backups in a configured PersistentVolumeClaim.
- `all`: both kinds of backups will be enabled.

Default is `none`.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value  |
|:-------|
|`"s3"`  |
|`"pvc"` |
|`"none"`|
|`"all"` |

## .spec.distribution.modules.dr.overrides

### Properties

| Property                                                        | Type     | Required |
|:----------------------------------------------------------------|:---------|:---------|
| [ingresses](#specdistributionmodulesdroverridesingresses)       | `object` | Optional |
| [nodeSelector](#specdistributionmodulesdroverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulesdroverridestolerations)   | `array`  | Optional |

### Description

Override the common configuration with a particular configuration for the module.

## .spec.distribution.modules.dr.overrides.ingresses

## .spec.distribution.modules.dr.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the module.

## .spec.distribution.modules.dr.overrides.tolerations

### Properties

| Property                                                           | Type     | Required |
|:-------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulesdroverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulesdroverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulesdroverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulesdroverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the module.

## .spec.distribution.modules.dr.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.dr.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.dr.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.dr.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.dr.type

### Description

The type of the Disaster Recovery, must be `none` or `on-premises`. `none` disables the module and `on-premises` will install Velero, an optional MinIO deployment and optionally etcd-backup.

Default is `none`.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value         |
|:--------------|
|`"none"`       |
|`"on-premises"`|

## .spec.distribution.modules.dr.velero

### Properties

| Property                                                                 | Type     | Required |
|:-------------------------------------------------------------------------|:---------|:---------|
| [backend](#specdistributionmodulesdrvelerobackend)                       | `string` | Optional |
| [externalEndpoint](#specdistributionmodulesdrveleroexternalendpoint)     | `object` | Optional |
| [overrides](#specdistributionmodulesdrvelerooverrides)                   | `object` | Optional |
| [schedules](#specdistributionmodulesdrveleroschedules)                   | `object` | Optional |
| [snapshotController](#specdistributionmodulesdrvelerosnapshotcontroller) | `object` | Optional |

### Description

Configuration for the Velero package.

## .spec.distribution.modules.dr.velero.backend

### Description

The storage backend type for Velero. `minio` will use an in-cluster MinIO deployment for object storage, `externalEndpoint` can be used to point to an external S3-compatible object storage instead of deploying an in-cluster MinIO.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"minio"`           |
|`"externalEndpoint"`|

## .spec.distribution.modules.dr.velero.externalEndpoint

### Properties

| Property                                                                           | Type      | Required |
|:-----------------------------------------------------------------------------------|:----------|:---------|
| [accessKeyId](#specdistributionmodulesdrveleroexternalendpointaccesskeyid)         | `string`  | Optional |
| [bucketName](#specdistributionmodulesdrveleroexternalendpointbucketname)           | `string`  | Optional |
| [endpoint](#specdistributionmodulesdrveleroexternalendpointendpoint)               | `string`  | Optional |
| [insecure](#specdistributionmodulesdrveleroexternalendpointinsecure)               | `boolean` | Optional |
| [secretAccessKey](#specdistributionmodulesdrveleroexternalendpointsecretaccesskey) | `string`  | Optional |

### Description

Configuration for Velero's external storage backend.

## .spec.distribution.modules.dr.velero.externalEndpoint.accessKeyId

### Description

The access key ID (username) for the external S3-compatible bucket.

## .spec.distribution.modules.dr.velero.externalEndpoint.bucketName

### Description

The bucket name of the external S3-compatible object storage.

## .spec.distribution.modules.dr.velero.externalEndpoint.endpoint

### Description

External S3-compatible endpoint for Velero's storage.

## .spec.distribution.modules.dr.velero.externalEndpoint.insecure

### Description

If true, will use HTTP as protocol instead of HTTPS.

## .spec.distribution.modules.dr.velero.externalEndpoint.secretAccessKey

### Description

The secret access key (password) for the external S3-compatible bucket.

## .spec.distribution.modules.dr.velero.overrides

### Properties

| Property                                                              | Type     | Required |
|:----------------------------------------------------------------------|:---------|:---------|
| [nodeSelector](#specdistributionmodulesdrvelerooverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulesdrvelerooverridestolerations)   | `array`  | Optional |

## .spec.distribution.modules.dr.velero.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the package.

## .spec.distribution.modules.dr.velero.overrides.tolerations

### Properties

| Property                                                                 | Type     | Required |
|:-------------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulesdrvelerooverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulesdrvelerooverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulesdrvelerooverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulesdrvelerooverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the package.

## .spec.distribution.modules.dr.velero.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.dr.velero.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.dr.velero.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.dr.velero.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.dr.velero.schedules

### Properties

| Property                                                            | Type      | Required |
|:--------------------------------------------------------------------|:----------|:---------|
| [definitions](#specdistributionmodulesdrveleroschedulesdefinitions) | `object`  | Optional |
| [install](#specdistributionmodulesdrveleroschedulesinstall)         | `boolean` | Optional |

### Description

Configuration for Velero's backup schedules.

## .spec.distribution.modules.dr.velero.schedules.definitions

### Properties

| Property                                                                   | Type     | Required |
|:---------------------------------------------------------------------------|:---------|:---------|
| [full](#specdistributionmodulesdrveleroschedulesdefinitionsfull)           | `object` | Optional |
| [manifests](#specdistributionmodulesdrveleroschedulesdefinitionsmanifests) | `object` | Optional |

### Description

Configuration for Velero schedules.

## .spec.distribution.modules.dr.velero.schedules.definitions.full

### Properties

| Property                                                                                     | Type      | Required |
|:---------------------------------------------------------------------------------------------|:----------|:---------|
| [schedule](#specdistributionmodulesdrveleroschedulesdefinitionsfullschedule)                 | `string`  | Optional |
| [snapshotMoveData](#specdistributionmodulesdrveleroschedulesdefinitionsfullsnapshotmovedata) | `boolean` | Optional |
| [ttl](#specdistributionmodulesdrveleroschedulesdefinitionsfullttl)                           | `string`  | Optional |

### Description

Configuration for Velero's manifests backup schedule.

## .spec.distribution.modules.dr.velero.schedules.definitions.full.schedule

### Description

The cron expression for the `full` backup schedule (default `0 1 * * *`).

## .spec.distribution.modules.dr.velero.schedules.definitions.full.snapshotMoveData

### Description

EXPERIMENTAL (if you do more than one backups, the following backups after the first are not automatically restorable, see https://github.com/vmware-tanzu/velero/issues/7057#issuecomment-2466815898 for the manual restore solution): SnapshotMoveData specifies whether snapshot data should be moved. Velero will create a new volume from the snapshot and upload the content to the storageLocation.

## .spec.distribution.modules.dr.velero.schedules.definitions.full.ttl

### Description

The Time To Live (TTL) of the backups created by the backup schedules (default `720h0m0s`, 30 days). Notice that changing this value will affect only newly created backups, prior backups will keep the old TTL.

## .spec.distribution.modules.dr.velero.schedules.definitions.manifests

### Properties

| Property                                                                          | Type     | Required |
|:----------------------------------------------------------------------------------|:---------|:---------|
| [schedule](#specdistributionmodulesdrveleroschedulesdefinitionsmanifestsschedule) | `string` | Optional |
| [ttl](#specdistributionmodulesdrveleroschedulesdefinitionsmanifeststtl)           | `string` | Optional |

### Description

Configuration for Velero's manifests backup schedule.

## .spec.distribution.modules.dr.velero.schedules.definitions.manifests.schedule

### Description

The cron expression for the `manifests` backup schedule (default `*/15 * * * *`).

## .spec.distribution.modules.dr.velero.schedules.definitions.manifests.ttl

### Description

The Time To Live (TTL) of the backups created by the backup schedules (default `720h0m0s`, 30 days). Notice that changing this value will affect only newly created backups, prior backups will keep the old TTL.

## .spec.distribution.modules.dr.velero.schedules.install

### Description

Whether to install or not the default `manifests` and `full` backups schedules. Default is `true`.

## .spec.distribution.modules.dr.velero.snapshotController

### Properties

| Property                                                             | Type      | Required |
|:---------------------------------------------------------------------|:----------|:---------|
| [install](#specdistributionmodulesdrvelerosnapshotcontrollerinstall) | `boolean` | Optional |

### Description

Configuration for the additional snapshotController component installation.

## .spec.distribution.modules.dr.velero.snapshotController.install

### Description

Whether to install or not the snapshotController component in the cluster. Before enabling this field, check if your CSI driver does not have snapshotController built-in.

## .spec.distribution.modules.ingress

### Properties

| Property                                                  | Type     | Required |
|:----------------------------------------------------------|:---------|:---------|
| [baseDomain](#specdistributionmodulesingressbasedomain)   | `string` | Required |
| [certManager](#specdistributionmodulesingresscertmanager) | `object` | Optional |
| [forecastle](#specdistributionmodulesingressforecastle)   | `object` | Optional |
| [nginx](#specdistributionmodulesingressnginx)             | `object` | Required |
| [overrides](#specdistributionmodulesingressoverrides)     | `object` | Optional |
| [then](#specdistributionmodulesingressthen)               | `object` | Optional |

## .spec.distribution.modules.ingress.baseDomain

### Description

The base domain used for all the KFD infrastructural ingresses. If using the nginx `dual` type, this value should be the same as the domain associated with the `internal` ingress class.

## .spec.distribution.modules.ingress.certManager

### Properties

| Property                                                                 | Type     | Required |
|:-------------------------------------------------------------------------|:---------|:---------|
| [clusterIssuer](#specdistributionmodulesingresscertmanagerclusterissuer) | `object` | Required |
| [overrides](#specdistributionmodulesingresscertmanageroverrides)         | `object` | Optional |

### Description

Configuration for the cert-manager package. Required even if `ingress.nginx.type` is `none`, cert-manager is used for managing other certificates in the cluster besides the TLS termination certificates for the ingresses.

## .spec.distribution.modules.ingress.certManager.clusterIssuer

### Properties

| Property                                                                  | Type     | Required |
|:--------------------------------------------------------------------------|:---------|:---------|
| [email](#specdistributionmodulesingresscertmanagerclusterissueremail)     | `string` | Required |
| [name](#specdistributionmodulesingresscertmanagerclusterissuername)       | `string` | Required |
| [solvers](#specdistributionmodulesingresscertmanagerclusterissuersolvers) | `array`  | Optional |
| [type](#specdistributionmodulesingresscertmanagerclusterissuertype)       | `string` | Optional |

### Description

Configuration for the cert-manager's ACME clusterIssuer used to request certificates from Let's Encrypt.

## .spec.distribution.modules.ingress.certManager.clusterIssuer.email

### Description

The email address to use during the certificate issuing process.

## .spec.distribution.modules.ingress.certManager.clusterIssuer.name

### Description

The name of the clusterIssuer.

## .spec.distribution.modules.ingress.certManager.clusterIssuer.solvers

### Description

The list of challenge solvers to use instead of the default one for the `http01` challenge. Check [cert manager's documentation](https://cert-manager.io/docs/configuration/acme/#adding-multiple-solver-types) for examples for this field.

## .spec.distribution.modules.ingress.certManager.clusterIssuer.type

### Description

The type of the clusterIssuer. Only `http01` challenge is supported for on-premises clusters. See solvers for arbitrary configurations.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"http01"`|

## .spec.distribution.modules.ingress.certManager.overrides

### Properties

| Property                                                                        | Type     | Required |
|:--------------------------------------------------------------------------------|:---------|:---------|
| [nodeSelector](#specdistributionmodulesingresscertmanageroverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulesingresscertmanageroverridestolerations)   | `array`  | Optional |

## .spec.distribution.modules.ingress.certManager.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the package.

## .spec.distribution.modules.ingress.certManager.overrides.tolerations

### Properties

| Property                                                                           | Type     | Required |
|:-----------------------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulesingresscertmanageroverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulesingresscertmanageroverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulesingresscertmanageroverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulesingresscertmanageroverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the package.

## .spec.distribution.modules.ingress.certManager.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.ingress.certManager.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.ingress.certManager.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.ingress.certManager.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.ingress.forecastle

### Properties

| Property                                                        | Type     | Required |
|:----------------------------------------------------------------|:---------|:---------|
| [overrides](#specdistributionmodulesingressforecastleoverrides) | `object` | Optional |

## .spec.distribution.modules.ingress.forecastle.overrides

### Properties

| Property                                                                       | Type     | Required |
|:-------------------------------------------------------------------------------|:---------|:---------|
| [nodeSelector](#specdistributionmodulesingressforecastleoverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulesingressforecastleoverridestolerations)   | `array`  | Optional |

## .spec.distribution.modules.ingress.forecastle.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the package.

## .spec.distribution.modules.ingress.forecastle.overrides.tolerations

### Properties

| Property                                                                          | Type     | Required |
|:----------------------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulesingressforecastleoverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulesingressforecastleoverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulesingressforecastleoverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulesingressforecastleoverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the package.

## .spec.distribution.modules.ingress.forecastle.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.ingress.forecastle.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.ingress.forecastle.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.ingress.forecastle.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.ingress.nginx

### Properties

| Property                                                   | Type     | Required |
|:-----------------------------------------------------------|:---------|:---------|
| [overrides](#specdistributionmodulesingressnginxoverrides) | `object` | Optional |
| [tls](#specdistributionmodulesingressnginxtls)             | `object` | Optional |
| [type](#specdistributionmodulesingressnginxtype)           | `string` | Required |

### Description

Configurations for the Ingress nginx controller package.

## .spec.distribution.modules.ingress.nginx.overrides

### Properties

| Property                                                                  | Type     | Required |
|:--------------------------------------------------------------------------|:---------|:---------|
| [nodeSelector](#specdistributionmodulesingressnginxoverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulesingressnginxoverridestolerations)   | `array`  | Optional |

## .spec.distribution.modules.ingress.nginx.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the package.

## .spec.distribution.modules.ingress.nginx.overrides.tolerations

### Properties

| Property                                                                     | Type     | Required |
|:-----------------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulesingressnginxoverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulesingressnginxoverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulesingressnginxoverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulesingressnginxoverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the package.

## .spec.distribution.modules.ingress.nginx.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.ingress.nginx.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.ingress.nginx.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.ingress.nginx.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.ingress.nginx.tls

### Properties

| Property                                                    | Type     | Required |
|:------------------------------------------------------------|:---------|:---------|
| [provider](#specdistributionmodulesingressnginxtlsprovider) | `string` | Required |
| [secret](#specdistributionmodulesingressnginxtlssecret)     | `object` | Optional |

## .spec.distribution.modules.ingress.nginx.tls.provider

### Description

The provider of the TLS certificates for the ingresses, one of: `none`, `certManager`, or `secret`.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value         |
|:--------------|
|`"certManager"`|
|`"secret"`     |
|`"none"`       |

## .spec.distribution.modules.ingress.nginx.tls.secret

### Properties

| Property                                                  | Type     | Required |
|:----------------------------------------------------------|:---------|:---------|
| [ca](#specdistributionmodulesingressnginxtlssecretca)     | `string` | Required |
| [cert](#specdistributionmodulesingressnginxtlssecretcert) | `string` | Required |
| [key](#specdistributionmodulesingressnginxtlssecretkey)   | `string` | Required |

### Description

Kubernetes TLS secret for the ingresses TLS certificate.

## .spec.distribution.modules.ingress.nginx.tls.secret.ca

### Description

The Certificate Authority certificate file's content. You can use the `"{file://<path>}"` notation to get the content from a file.

## .spec.distribution.modules.ingress.nginx.tls.secret.cert

### Description

The certificate file's content. You can use the `"{file://<path>}"` notation to get the content from a file.

## .spec.distribution.modules.ingress.nginx.tls.secret.key

### Description

The signing key file's content. You can use the `"{file://<path>}"` notation to get the content from a file.

## .spec.distribution.modules.ingress.nginx.type

### Description

The type of the Ingress nginx controller, options are:
- `none`: no ingress controller will be installed and no infrastructural ingresses will be created.
- `single`: a single ingress controller with ingress class `nginx` will be installed to manage all the ingress resources, infrastructural ingresses will be created.
- `dual`: two independent ingress controllers will be installed, one for the `internal` ingress class intended for private ingresses and one for the `external` ingress class intended for public ingresses. KFD infrastructural ingresses wil use the `internal` ingress class when using the dual type.

Default is `single`.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"none"`  |
|`"single"`|
|`"dual"`  |

## .spec.distribution.modules.ingress.overrides

### Properties

| Property                                                             | Type     | Required |
|:---------------------------------------------------------------------|:---------|:---------|
| [ingresses](#specdistributionmodulesingressoverridesingresses)       | `object` | Optional |
| [nodeSelector](#specdistributionmodulesingressoverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulesingressoverridestolerations)   | `array`  | Optional |

### Description

Override the common configuration with a particular configuration for the Ingress module.

## .spec.distribution.modules.ingress.overrides.ingresses

### Properties

| Property                                                                  | Type     | Required |
|:--------------------------------------------------------------------------|:---------|:---------|
| [forecastle](#specdistributionmodulesingressoverridesingressesforecastle) | `object` | Optional |

## .spec.distribution.modules.ingress.overrides.ingresses.forecastle

### Properties

| Property                                                                                | Type      | Required |
|:----------------------------------------------------------------------------------------|:----------|:---------|
| [disableAuth](#specdistributionmodulesingressoverridesingressesforecastledisableauth)   | `boolean` | Optional |
| [host](#specdistributionmodulesingressoverridesingressesforecastlehost)                 | `string`  | Optional |
| [ingressClass](#specdistributionmodulesingressoverridesingressesforecastleingressclass) | `string`  | Optional |

## .spec.distribution.modules.ingress.overrides.ingresses.forecastle.disableAuth

### Description

If true, the ingress will not have authentication even if `.spec.modules.auth.provider.type` is SSO or Basic Auth.

## .spec.distribution.modules.ingress.overrides.ingresses.forecastle.host

### Description

Use this host for the ingress instead of the default one.

## .spec.distribution.modules.ingress.overrides.ingresses.forecastle.ingressClass

### Description

Use this ingress class for the ingress instead of the default one.

## .spec.distribution.modules.ingress.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the Ingress module.

## .spec.distribution.modules.ingress.overrides.tolerations

### Properties

| Property                                                                | Type     | Required |
|:------------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulesingressoverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulesingressoverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulesingressoverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulesingressoverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the Ingress module.

## .spec.distribution.modules.ingress.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.ingress.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.ingress.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.ingress.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.ingress.then

## .spec.distribution.modules.logging

### Properties

| Property                                                      | Type     | Required |
|:--------------------------------------------------------------|:---------|:---------|
| [cerebro](#specdistributionmodulesloggingcerebro)             | `object` | Optional |
| [customOutputs](#specdistributionmodulesloggingcustomoutputs) | `object` | Optional |
| [loki](#specdistributionmodulesloggingloki)                   | `object` | Optional |
| [minio](#specdistributionmodulesloggingminio)                 | `object` | Optional |
| [opensearch](#specdistributionmodulesloggingopensearch)       | `object` | Optional |
| [operator](#specdistributionmodulesloggingoperator)           | `object` | Optional |
| [overrides](#specdistributionmodulesloggingoverrides)         | `object` | Optional |
| [type](#specdistributionmodulesloggingtype)                   | `string` | Required |

### Description

Configuration for the Logging module.

## .spec.distribution.modules.logging.cerebro

### Properties

| Property                                                     | Type     | Required |
|:-------------------------------------------------------------|:---------|:---------|
| [overrides](#specdistributionmodulesloggingcerebrooverrides) | `object` | Optional |

### Description

DEPRECATED since KFD v1.26.6, 1.27.5, v1.28.0.

## .spec.distribution.modules.logging.cerebro.overrides

### Properties

| Property                                                                    | Type     | Required |
|:----------------------------------------------------------------------------|:---------|:---------|
| [nodeSelector](#specdistributionmodulesloggingcerebrooverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulesloggingcerebrooverridestolerations)   | `array`  | Optional |

## .spec.distribution.modules.logging.cerebro.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the package.

## .spec.distribution.modules.logging.cerebro.overrides.tolerations

### Properties

| Property                                                                       | Type     | Required |
|:-------------------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulesloggingcerebrooverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulesloggingcerebrooverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulesloggingcerebrooverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulesloggingcerebrooverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the package.

## .spec.distribution.modules.logging.cerebro.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.logging.cerebro.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.logging.cerebro.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.logging.cerebro.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.logging.customOutputs

### Properties

| Property                                                                   | Type     | Required |
|:---------------------------------------------------------------------------|:---------|:---------|
| [audit](#specdistributionmodulesloggingcustomoutputsaudit)                 | `string` | Required |
| [errors](#specdistributionmodulesloggingcustomoutputserrors)               | `string` | Required |
| [events](#specdistributionmodulesloggingcustomoutputsevents)               | `string` | Required |
| [infra](#specdistributionmodulesloggingcustomoutputsinfra)                 | `string` | Required |
| [ingressNginx](#specdistributionmodulesloggingcustomoutputsingressnginx)   | `string` | Required |
| [kubernetes](#specdistributionmodulesloggingcustomoutputskubernetes)       | `string` | Required |
| [systemdCommon](#specdistributionmodulesloggingcustomoutputssystemdcommon) | `string` | Required |
| [systemdEtcd](#specdistributionmodulesloggingcustomoutputssystemdetcd)     | `string` | Required |

### Description

When using the `customOutputs` logging type, you need to manually specify the spec of the several `Output` and `ClusterOutputs` that the Logging Operator expects to forward the logs collected by the pre-defined flows.

## .spec.distribution.modules.logging.customOutputs.audit

### Description

This value defines where the output from the `audit` Flow will be sent. This will be the `spec` section of the `Output` object. It must be a string (and not a YAML object) following the OutputSpec definition. Use the `nullout` output to discard the flow: `nullout: {}`

## .spec.distribution.modules.logging.customOutputs.errors

### Description

This value defines where the output from the `errors` Flow will be sent. This will be the `spec` section of the `Output` object. It must be a string (and not a YAML object) following the OutputSpec definition. Use the `nullout` output to discard the flow: `nullout: {}`

## .spec.distribution.modules.logging.customOutputs.events

### Description

This value defines where the output from the `events` Flow will be sent. This will be the `spec` section of the `Output` object. It must be a string (and not a YAML object) following the OutputSpec definition. Use the `nullout` output to discard the flow: `nullout: {}`

## .spec.distribution.modules.logging.customOutputs.infra

### Description

This value defines where the output from the `infra` Flow will be sent. This will be the `spec` section of the `Output` object. It must be a string (and not a YAML object) following the OutputSpec definition. Use the `nullout` output to discard the flow: `nullout: {}`

## .spec.distribution.modules.logging.customOutputs.ingressNginx

### Description

This value defines where the output from the `ingressNginx` Flow will be sent. This will be the `spec` section of the `Output` object. It must be a string (and not a YAML object) following the OutputSpec definition. Use the `nullout` output to discard the flow: `nullout: {}`

## .spec.distribution.modules.logging.customOutputs.kubernetes

### Description

This value defines where the output from the `kubernetes` Flow will be sent. This will be the `spec` section of the `Output` object. It must be a string (and not a YAML object) following the OutputSpec definition. Use the `nullout` output to discard the flow: `nullout: {}`

## .spec.distribution.modules.logging.customOutputs.systemdCommon

### Description

This value defines where the output from the `systemdCommon` Flow will be sent. This will be the `spec` section of the `Output` object. It must be a string (and not a YAML object) following the OutputSpec definition. Use the `nullout` output to discard the flow: `nullout: {}`

## .spec.distribution.modules.logging.customOutputs.systemdEtcd

### Description

This value defines where the output from the `systemdEtcd` Flow will be sent. This will be the `spec` section of the `Output` object. It must be a string (and not a YAML object) following the OutputSpec definition. Use the `nullout` output to discard the flow: `nullout: {}`

## .spec.distribution.modules.logging.loki

### Properties

| Property                                                                | Type     | Required |
|:------------------------------------------------------------------------|:---------|:---------|
| [backend](#specdistributionmoduleslogginglokibackend)                   | `string` | Optional |
| [externalEndpoint](#specdistributionmoduleslogginglokiexternalendpoint) | `object` | Optional |
| [resources](#specdistributionmoduleslogginglokiresources)               | `object` | Optional |
| [retentionTime](#specdistributionmoduleslogginglokiretentiontime)       | `string` | Optional |
| [tsdbStartDate](#specdistributionmoduleslogginglokitsdbstartdate)       | `string` | Optional |

### Description

Configuration for the Loki package.

## .spec.distribution.modules.logging.loki.backend

### Description

The storage backend type for Loki. `minio` will use an in-cluster MinIO deployment for object storage, `externalEndpoint` can be used to point to an external object storage instead of deploying an in-cluster MinIO.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"minio"`           |
|`"externalEndpoint"`|

## .spec.distribution.modules.logging.loki.externalEndpoint

### Properties

| Property                                                                              | Type      | Required |
|:--------------------------------------------------------------------------------------|:----------|:---------|
| [accessKeyId](#specdistributionmoduleslogginglokiexternalendpointaccesskeyid)         | `string`  | Optional |
| [bucketName](#specdistributionmoduleslogginglokiexternalendpointbucketname)           | `string`  | Optional |
| [endpoint](#specdistributionmoduleslogginglokiexternalendpointendpoint)               | `string`  | Optional |
| [insecure](#specdistributionmoduleslogginglokiexternalendpointinsecure)               | `boolean` | Optional |
| [secretAccessKey](#specdistributionmoduleslogginglokiexternalendpointsecretaccesskey) | `string`  | Optional |

### Description

Configuration for Loki's external storage backend.

## .spec.distribution.modules.logging.loki.externalEndpoint.accessKeyId

### Description

The access key ID (username) for the external S3-compatible bucket.

## .spec.distribution.modules.logging.loki.externalEndpoint.bucketName

### Description

The bucket name of the external S3-compatible object storage.

## .spec.distribution.modules.logging.loki.externalEndpoint.endpoint

### Description

External S3-compatible endpoint for Loki's storage.

## .spec.distribution.modules.logging.loki.externalEndpoint.insecure

### Description

If true, will use HTTP as protocol instead of HTTPS.

## .spec.distribution.modules.logging.loki.externalEndpoint.secretAccessKey

### Description

The secret access key (password) for the external S3-compatible bucket.

## .spec.distribution.modules.logging.loki.resources

### Properties

| Property                                                         | Type     | Required |
|:-----------------------------------------------------------------|:---------|:---------|
| [limits](#specdistributionmoduleslogginglokiresourceslimits)     | `object` | Optional |
| [requests](#specdistributionmoduleslogginglokiresourcesrequests) | `object` | Optional |

## .spec.distribution.modules.logging.loki.resources.limits

### Properties

| Property                                                           | Type     | Required |
|:-------------------------------------------------------------------|:---------|:---------|
| [cpu](#specdistributionmoduleslogginglokiresourceslimitscpu)       | `string` | Optional |
| [memory](#specdistributionmoduleslogginglokiresourceslimitsmemory) | `string` | Optional |

## .spec.distribution.modules.logging.loki.resources.limits.cpu

### Description

The CPU limit for the Pod. Example: `1000m`.

## .spec.distribution.modules.logging.loki.resources.limits.memory

### Description

The memory limit for the Pod. Example: `1G`.

## .spec.distribution.modules.logging.loki.resources.requests

### Properties

| Property                                                             | Type     | Required |
|:---------------------------------------------------------------------|:---------|:---------|
| [cpu](#specdistributionmoduleslogginglokiresourcesrequestscpu)       | `string` | Optional |
| [memory](#specdistributionmoduleslogginglokiresourcesrequestsmemory) | `string` | Optional |

## .spec.distribution.modules.logging.loki.resources.requests.cpu

### Description

The CPU request for the Pod, in cores. Example: `500m`.

## .spec.distribution.modules.logging.loki.resources.requests.memory

### Description

The memory request for the Pod. Example: `500M`.

## .spec.distribution.modules.logging.loki.retentionTime

### Description

Optional retention period for logs stored in Loki (default `720h`, 30 days). Setting it to `0s` disables retention. Format must match: `[0-9]+(s|m|h|d|w|y)`.

## .spec.distribution.modules.logging.loki.tsdbStartDate

### Description

Starting from versions 1.28.4, 1.29.5 and 1.30.0 of SIGHUP Distribution, Loki changed the time series database from BoltDB to TSDB and the schema that it uses to store the logs from v11 to v13.

The value of this field will determine the date when Loki will start writing using the new TSDB and the schema v13, always at midnight UTC. The old BoltDB and schema will be kept until all the logs expire for reading purposes.

From versions 1.29.7, 1.30.2 and 1.31.1 of the Distribution, this field will be immutable once set and its value should be a date before upgrading to one of these versions or creating the cluster, Loki does not support writing BoltDB and schema v11 anymore.

Value must be a string in `ISO 8601` date format (`yyyy-mm-dd`). Example: `2024-11-18`.

## .spec.distribution.modules.logging.minio

### Properties

| Property                                                       | Type     | Required |
|:---------------------------------------------------------------|:---------|:---------|
| [overrides](#specdistributionmodulesloggingminiooverrides)     | `object` | Optional |
| [rootUser](#specdistributionmodulesloggingminiorootuser)       | `object` | Optional |
| [storageSize](#specdistributionmodulesloggingminiostoragesize) | `string` | Optional |

### Description

Configuration for Logging's MinIO deployment.

## .spec.distribution.modules.logging.minio.overrides

### Properties

| Property                                                                  | Type     | Required |
|:--------------------------------------------------------------------------|:---------|:---------|
| [nodeSelector](#specdistributionmodulesloggingminiooverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulesloggingminiooverridestolerations)   | `array`  | Optional |

## .spec.distribution.modules.logging.minio.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the package.

## .spec.distribution.modules.logging.minio.overrides.tolerations

### Properties

| Property                                                                     | Type     | Required |
|:-----------------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulesloggingminiooverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulesloggingminiooverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulesloggingminiooverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulesloggingminiooverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the package.

## .spec.distribution.modules.logging.minio.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.logging.minio.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.logging.minio.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.logging.minio.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.logging.minio.rootUser

### Properties

| Property                                                         | Type     | Required |
|:-----------------------------------------------------------------|:---------|:---------|
| [password](#specdistributionmodulesloggingminiorootuserpassword) | `string` | Optional |
| [username](#specdistributionmodulesloggingminiorootuserusername) | `string` | Optional |

## .spec.distribution.modules.logging.minio.rootUser.password

### Description

The password for the default MinIO root user.

## .spec.distribution.modules.logging.minio.rootUser.username

### Description

The username for the default MinIO root user.

## .spec.distribution.modules.logging.minio.storageSize

### Description

The PVC size for each MinIO disk, 6 disks total.

## .spec.distribution.modules.logging.opensearch

### Properties

| Property                                                            | Type     | Required |
|:--------------------------------------------------------------------|:---------|:---------|
| [overrides](#specdistributionmodulesloggingopensearchoverrides)     | `object` | Optional |
| [resources](#specdistributionmodulesloggingopensearchresources)     | `object` | Optional |
| [storageSize](#specdistributionmodulesloggingopensearchstoragesize) | `string` | Optional |
| [type](#specdistributionmodulesloggingopensearchtype)               | `string` | Required |

## .spec.distribution.modules.logging.opensearch.overrides

### Properties

| Property                                                                       | Type     | Required |
|:-------------------------------------------------------------------------------|:---------|:---------|
| [nodeSelector](#specdistributionmodulesloggingopensearchoverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulesloggingopensearchoverridestolerations)   | `array`  | Optional |

## .spec.distribution.modules.logging.opensearch.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the package.

## .spec.distribution.modules.logging.opensearch.overrides.tolerations

### Properties

| Property                                                                          | Type     | Required |
|:----------------------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulesloggingopensearchoverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulesloggingopensearchoverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulesloggingopensearchoverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulesloggingopensearchoverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the package.

## .spec.distribution.modules.logging.opensearch.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.logging.opensearch.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.logging.opensearch.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.logging.opensearch.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.logging.opensearch.resources

### Properties

| Property                                                               | Type     | Required |
|:-----------------------------------------------------------------------|:---------|:---------|
| [limits](#specdistributionmodulesloggingopensearchresourceslimits)     | `object` | Optional |
| [requests](#specdistributionmodulesloggingopensearchresourcesrequests) | `object` | Optional |

## .spec.distribution.modules.logging.opensearch.resources.limits

### Properties

| Property                                                                 | Type     | Required |
|:-------------------------------------------------------------------------|:---------|:---------|
| [cpu](#specdistributionmodulesloggingopensearchresourceslimitscpu)       | `string` | Optional |
| [memory](#specdistributionmodulesloggingopensearchresourceslimitsmemory) | `string` | Optional |

## .spec.distribution.modules.logging.opensearch.resources.limits.cpu

### Description

The CPU limit for the Pod. Example: `1000m`.

## .spec.distribution.modules.logging.opensearch.resources.limits.memory

### Description

The memory limit for the Pod. Example: `1G`.

## .spec.distribution.modules.logging.opensearch.resources.requests

### Properties

| Property                                                                   | Type     | Required |
|:---------------------------------------------------------------------------|:---------|:---------|
| [cpu](#specdistributionmodulesloggingopensearchresourcesrequestscpu)       | `string` | Optional |
| [memory](#specdistributionmodulesloggingopensearchresourcesrequestsmemory) | `string` | Optional |

## .spec.distribution.modules.logging.opensearch.resources.requests.cpu

### Description

The CPU request for the Pod, in cores. Example: `500m`.

## .spec.distribution.modules.logging.opensearch.resources.requests.memory

### Description

The memory request for the Pod. Example: `500M`.

## .spec.distribution.modules.logging.opensearch.storageSize

### Description

The storage size for the OpenSearch volumes. Follows Kubernetes resources storage requests. Default is `150Gi`.

## .spec.distribution.modules.logging.opensearch.type

### Description

The type of OpenSearch deployment. One of: `single` for a single replica or `triple` for an HA 3-replicas deployment.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"single"`|
|`"triple"`|

## .spec.distribution.modules.logging.operator

### Properties

| Property                                                      | Type     | Required |
|:--------------------------------------------------------------|:---------|:---------|
| [overrides](#specdistributionmodulesloggingoperatoroverrides) | `object` | Optional |

### Description

Configuration for the Logging Operator.

## .spec.distribution.modules.logging.operator.overrides

### Properties

| Property                                                                     | Type     | Required |
|:-----------------------------------------------------------------------------|:---------|:---------|
| [nodeSelector](#specdistributionmodulesloggingoperatoroverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulesloggingoperatoroverridestolerations)   | `array`  | Optional |

## .spec.distribution.modules.logging.operator.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the package.

## .spec.distribution.modules.logging.operator.overrides.tolerations

### Properties

| Property                                                                        | Type     | Required |
|:--------------------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulesloggingoperatoroverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulesloggingoperatoroverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulesloggingoperatoroverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulesloggingoperatoroverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the package.

## .spec.distribution.modules.logging.operator.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.logging.operator.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.logging.operator.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.logging.operator.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.logging.overrides

### Properties

| Property                                                             | Type     | Required |
|:---------------------------------------------------------------------|:---------|:---------|
| [ingresses](#specdistributionmodulesloggingoverridesingresses)       | `object` | Optional |
| [nodeSelector](#specdistributionmodulesloggingoverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulesloggingoverridestolerations)   | `array`  | Optional |

### Description

Override the common configuration with a particular configuration for the module.

## .spec.distribution.modules.logging.overrides.ingresses

## .spec.distribution.modules.logging.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the module.

## .spec.distribution.modules.logging.overrides.tolerations

### Properties

| Property                                                                | Type     | Required |
|:------------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulesloggingoverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulesloggingoverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulesloggingoverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulesloggingoverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the module.

## .spec.distribution.modules.logging.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.logging.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.logging.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.logging.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.logging.type

### Description

Selects the logging stack. Options are:
- `none`: will disable the centralized logging.
- `opensearch`: will deploy and configure the Logging Operator and an OpenSearch cluster (can be single or triple for HA) where the logs will be stored.
- `loki`: will use a distributed Grafana Loki instead of OpenSearch for storage.
- `customOuputs`: the Logging Operator will be deployed and installed but without in-cluster storage, you will have to create the needed Outputs and ClusterOutputs to ship the logs to your desired storage.

Default is `opensearch`.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value           |
|:----------------|
|`"none"`         |
|`"opensearch"`   |
|`"loki"`         |
|`"customOutputs"`|

## .spec.distribution.modules.monitoring

### Properties

| Property                                                                 | Type     | Required |
|:-------------------------------------------------------------------------|:---------|:---------|
| [alertmanager](#specdistributionmodulesmonitoringalertmanager)           | `object` | Optional |
| [blackboxExporter](#specdistributionmodulesmonitoringblackboxexporter)   | `object` | Optional |
| [grafana](#specdistributionmodulesmonitoringgrafana)                     | `object` | Optional |
| [kubeStateMetrics](#specdistributionmodulesmonitoringkubestatemetrics)   | `object` | Optional |
| [mimir](#specdistributionmodulesmonitoringmimir)                         | `object` | Optional |
| [minio](#specdistributionmodulesmonitoringminio)                         | `object` | Optional |
| [overrides](#specdistributionmodulesmonitoringoverrides)                 | `object` | Optional |
| [prometheus](#specdistributionmodulesmonitoringprometheus)               | `object` | Optional |
| [prometheusAdapter](#specdistributionmodulesmonitoringprometheusadapter) | `object` | Optional |
| [prometheusAgent](#specdistributionmodulesmonitoringprometheusagent)     | `object` | Optional |
| [type](#specdistributionmodulesmonitoringtype)                           | `string` | Required |
| [x509Exporter](#specdistributionmodulesmonitoringx509exporter)           | `object` | Optional |

### Description

Configuration for the Monitoring module.

## .spec.distribution.modules.monitoring.alertmanager

### Properties

| Property                                                                                         | Type      | Required |
|:-------------------------------------------------------------------------------------------------|:----------|:---------|
| [deadManSwitchWebhookUrl](#specdistributionmodulesmonitoringalertmanagerdeadmanswitchwebhookurl) | `string`  | Optional |
| [installDefaultRules](#specdistributionmodulesmonitoringalertmanagerinstalldefaultrules)         | `boolean` | Optional |
| [slackWebhookUrl](#specdistributionmodulesmonitoringalertmanagerslackwebhookurl)                 | `string`  | Optional |

## .spec.distribution.modules.monitoring.alertmanager.deadManSwitchWebhookUrl

### Description

The webhook URL to send dead man's switch monitoring, for example to use with healthchecks.io.

## .spec.distribution.modules.monitoring.alertmanager.installDefaultRules

### Description

Set to false to avoid installing the Prometheus rules (alerts) included with the distribution.

## .spec.distribution.modules.monitoring.alertmanager.slackWebhookUrl

### Description

The Slack webhook URL where to send the infrastructural and workload alerts to.

## .spec.distribution.modules.monitoring.blackboxExporter

### Properties

| Property                                                                 | Type     | Required |
|:-------------------------------------------------------------------------|:---------|:---------|
| [overrides](#specdistributionmodulesmonitoringblackboxexporteroverrides) | `object` | Optional |

## .spec.distribution.modules.monitoring.blackboxExporter.overrides

### Properties

| Property                                                                                | Type     | Required |
|:----------------------------------------------------------------------------------------|:---------|:---------|
| [nodeSelector](#specdistributionmodulesmonitoringblackboxexporteroverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulesmonitoringblackboxexporteroverridestolerations)   | `array`  | Optional |

## .spec.distribution.modules.monitoring.blackboxExporter.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the package.

## .spec.distribution.modules.monitoring.blackboxExporter.overrides.tolerations

### Properties

| Property                                                                                   | Type     | Required |
|:-------------------------------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulesmonitoringblackboxexporteroverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulesmonitoringblackboxexporteroverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulesmonitoringblackboxexporteroverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulesmonitoringblackboxexporteroverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the package.

## .spec.distribution.modules.monitoring.blackboxExporter.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.monitoring.blackboxExporter.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.monitoring.blackboxExporter.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.monitoring.blackboxExporter.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.monitoring.grafana

### Properties

| Property                                                                                  | Type      | Required |
|:------------------------------------------------------------------------------------------|:----------|:---------|
| [basicAuthIngress](#specdistributionmodulesmonitoringgrafanabasicauthingress)             | `boolean` | Optional |
| [overrides](#specdistributionmodulesmonitoringgrafanaoverrides)                           | `object`  | Optional |
| [usersRoleAttributePath](#specdistributionmodulesmonitoringgrafanausersroleattributepath) | `string`  | Optional |

## .spec.distribution.modules.monitoring.grafana.basicAuthIngress

### Description

Setting this to true will deploy an additional `grafana-basic-auth` ingress protected with Grafana's basic auth instead of SSO. It's intended use is as a temporary ingress for when there are problems with the SSO login flow.

Notice that by default anonymous access is enabled.

## .spec.distribution.modules.monitoring.grafana.overrides

### Properties

| Property                                                                       | Type     | Required |
|:-------------------------------------------------------------------------------|:---------|:---------|
| [nodeSelector](#specdistributionmodulesmonitoringgrafanaoverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulesmonitoringgrafanaoverridestolerations)   | `array`  | Optional |

## .spec.distribution.modules.monitoring.grafana.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the package.

## .spec.distribution.modules.monitoring.grafana.overrides.tolerations

### Properties

| Property                                                                          | Type     | Required |
|:----------------------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulesmonitoringgrafanaoverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulesmonitoringgrafanaoverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulesmonitoringgrafanaoverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulesmonitoringgrafanaoverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the package.

## .spec.distribution.modules.monitoring.grafana.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.monitoring.grafana.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.monitoring.grafana.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.monitoring.grafana.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.monitoring.grafana.usersRoleAttributePath

### Description

[JMESPath](http://jmespath.org/examples.html) expression to retrieve the user's role. Example:

```yaml
usersRoleAttributePath: "contains(groups[*], 'beta') && 'Admin' || contains(groups[*], 'gamma') && 'Editor' || contains(groups[*], 'delta') && 'Viewer'
```

More details in [Grafana's documentation](https://grafana.com/docs/grafana/latest/setup-grafana/configure-security/configure-authentication/generic-oauth/#configure-role-mapping).

## .spec.distribution.modules.monitoring.kubeStateMetrics

### Properties

| Property                                                                 | Type     | Required |
|:-------------------------------------------------------------------------|:---------|:---------|
| [overrides](#specdistributionmodulesmonitoringkubestatemetricsoverrides) | `object` | Optional |

## .spec.distribution.modules.monitoring.kubeStateMetrics.overrides

### Properties

| Property                                                                                | Type     | Required |
|:----------------------------------------------------------------------------------------|:---------|:---------|
| [nodeSelector](#specdistributionmodulesmonitoringkubestatemetricsoverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulesmonitoringkubestatemetricsoverridestolerations)   | `array`  | Optional |

## .spec.distribution.modules.monitoring.kubeStateMetrics.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the package.

## .spec.distribution.modules.monitoring.kubeStateMetrics.overrides.tolerations

### Properties

| Property                                                                                   | Type     | Required |
|:-------------------------------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulesmonitoringkubestatemetricsoverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulesmonitoringkubestatemetricsoverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulesmonitoringkubestatemetricsoverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulesmonitoringkubestatemetricsoverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the package.

## .spec.distribution.modules.monitoring.kubeStateMetrics.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.monitoring.kubeStateMetrics.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.monitoring.kubeStateMetrics.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.monitoring.kubeStateMetrics.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.monitoring.mimir

### Properties

| Property                                                                    | Type     | Required |
|:----------------------------------------------------------------------------|:---------|:---------|
| [backend](#specdistributionmodulesmonitoringmimirbackend)                   | `string` | Optional |
| [externalEndpoint](#specdistributionmodulesmonitoringmimirexternalendpoint) | `object` | Optional |
| [overrides](#specdistributionmodulesmonitoringmimiroverrides)               | `object` | Optional |
| [retentionTime](#specdistributionmodulesmonitoringmimirretentiontime)       | `string` | Optional |

### Description

Configuration for the Mimir package.

## .spec.distribution.modules.monitoring.mimir.backend

### Description

The storage backend type for Mimir. `minio` will use an in-cluster MinIO deployment for object storage, `externalEndpoint` can be used to point to an external S3-compatible object storage instead of deploying an in-cluster MinIO.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"minio"`           |
|`"externalEndpoint"`|

## .spec.distribution.modules.monitoring.mimir.externalEndpoint

### Properties

| Property                                                                                  | Type      | Required |
|:------------------------------------------------------------------------------------------|:----------|:---------|
| [accessKeyId](#specdistributionmodulesmonitoringmimirexternalendpointaccesskeyid)         | `string`  | Optional |
| [bucketName](#specdistributionmodulesmonitoringmimirexternalendpointbucketname)           | `string`  | Optional |
| [endpoint](#specdistributionmodulesmonitoringmimirexternalendpointendpoint)               | `string`  | Optional |
| [insecure](#specdistributionmodulesmonitoringmimirexternalendpointinsecure)               | `boolean` | Optional |
| [secretAccessKey](#specdistributionmodulesmonitoringmimirexternalendpointsecretaccesskey) | `string`  | Optional |

### Description

Configuration for Mimir's external storage backend.

## .spec.distribution.modules.monitoring.mimir.externalEndpoint.accessKeyId

### Description

The access key ID (username) for the external S3-compatible bucket.

## .spec.distribution.modules.monitoring.mimir.externalEndpoint.bucketName

### Description

The bucket name of the external S3-compatible object storage.

## .spec.distribution.modules.monitoring.mimir.externalEndpoint.endpoint

### Description

The external S3-compatible endpoint for Mimir's storage.

## .spec.distribution.modules.monitoring.mimir.externalEndpoint.insecure

### Description

If true, will use HTTP as protocol instead of HTTPS.

## .spec.distribution.modules.monitoring.mimir.externalEndpoint.secretAccessKey

### Description

The secret access key (password) for the external S3-compatible bucket.

## .spec.distribution.modules.monitoring.mimir.overrides

### Properties

| Property                                                                     | Type     | Required |
|:-----------------------------------------------------------------------------|:---------|:---------|
| [nodeSelector](#specdistributionmodulesmonitoringmimiroverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulesmonitoringmimiroverridestolerations)   | `array`  | Optional |

## .spec.distribution.modules.monitoring.mimir.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the package.

## .spec.distribution.modules.monitoring.mimir.overrides.tolerations

### Properties

| Property                                                                        | Type     | Required |
|:--------------------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulesmonitoringmimiroverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulesmonitoringmimiroverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulesmonitoringmimiroverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulesmonitoringmimiroverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the package.

## .spec.distribution.modules.monitoring.mimir.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.monitoring.mimir.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.monitoring.mimir.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.monitoring.mimir.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.monitoring.mimir.retentionTime

### Description

The retention time for the logs stored in Mimir. Default is `30d`. Value must match the regular expression `[0-9]+(ns|us|µs|ms|s|m|h|d|w|y)` where y = 365 days.

## .spec.distribution.modules.monitoring.minio

### Properties

| Property                                                          | Type     | Required |
|:------------------------------------------------------------------|:---------|:---------|
| [overrides](#specdistributionmodulesmonitoringminiooverrides)     | `object` | Optional |
| [rootUser](#specdistributionmodulesmonitoringminiorootuser)       | `object` | Optional |
| [storageSize](#specdistributionmodulesmonitoringminiostoragesize) | `string` | Optional |

### Description

Configuration for Monitoring's MinIO deployment.

## .spec.distribution.modules.monitoring.minio.overrides

### Properties

| Property                                                                     | Type     | Required |
|:-----------------------------------------------------------------------------|:---------|:---------|
| [nodeSelector](#specdistributionmodulesmonitoringminiooverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulesmonitoringminiooverridestolerations)   | `array`  | Optional |

## .spec.distribution.modules.monitoring.minio.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the package.

## .spec.distribution.modules.monitoring.minio.overrides.tolerations

### Properties

| Property                                                                        | Type     | Required |
|:--------------------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulesmonitoringminiooverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulesmonitoringminiooverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulesmonitoringminiooverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulesmonitoringminiooverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the package.

## .spec.distribution.modules.monitoring.minio.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.monitoring.minio.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.monitoring.minio.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.monitoring.minio.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.monitoring.minio.rootUser

### Properties

| Property                                                            | Type     | Required |
|:--------------------------------------------------------------------|:---------|:---------|
| [password](#specdistributionmodulesmonitoringminiorootuserpassword) | `string` | Optional |
| [username](#specdistributionmodulesmonitoringminiorootuserusername) | `string` | Optional |

## .spec.distribution.modules.monitoring.minio.rootUser.password

### Description

The password for the default MinIO root user.

## .spec.distribution.modules.monitoring.minio.rootUser.username

### Description

The username for the default MinIO root user.

## .spec.distribution.modules.monitoring.minio.storageSize

### Description

The PVC size for each MinIO disk, 6 disks total.

## .spec.distribution.modules.monitoring.overrides

### Properties

| Property                                                                | Type     | Required |
|:------------------------------------------------------------------------|:---------|:---------|
| [ingresses](#specdistributionmodulesmonitoringoverridesingresses)       | `object` | Optional |
| [nodeSelector](#specdistributionmodulesmonitoringoverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulesmonitoringoverridestolerations)   | `array`  | Optional |

### Description

Override the common configuration with a particular configuration for the module.

## .spec.distribution.modules.monitoring.overrides.ingresses

## .spec.distribution.modules.monitoring.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the module.

## .spec.distribution.modules.monitoring.overrides.tolerations

### Properties

| Property                                                                   | Type     | Required |
|:---------------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulesmonitoringoverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulesmonitoringoverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulesmonitoringoverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulesmonitoringoverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the module.

## .spec.distribution.modules.monitoring.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.monitoring.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.monitoring.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.monitoring.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.monitoring.prometheus

### Properties

| Property                                                                   | Type     | Required |
|:---------------------------------------------------------------------------|:---------|:---------|
| [remoteWrite](#specdistributionmodulesmonitoringprometheusremotewrite)     | `array`  | Optional |
| [resources](#specdistributionmodulesmonitoringprometheusresources)         | `object` | Optional |
| [retentionSize](#specdistributionmodulesmonitoringprometheusretentionsize) | `string` | Optional |
| [retentionTime](#specdistributionmodulesmonitoringprometheusretentiontime) | `string` | Optional |
| [storageSize](#specdistributionmodulesmonitoringprometheusstoragesize)     | `string` | Optional |

## .spec.distribution.modules.monitoring.prometheus.remoteWrite

### Description

Set this option to ship the collected metrics to a remote Prometheus receiver.

`remoteWrite` is an array of objects that allows configuring the [remoteWrite](https://prometheus.io/docs/specs/remote_write_spec/) options for Prometheus. The objects in the array follow [the same schema as in the prometheus operator](https://prometheus-operator.dev/docs/operator/api/#monitoring.coreos.com/v1.RemoteWriteSpec).

## .spec.distribution.modules.monitoring.prometheus.resources

### Properties

| Property                                                                  | Type     | Required |
|:--------------------------------------------------------------------------|:---------|:---------|
| [limits](#specdistributionmodulesmonitoringprometheusresourceslimits)     | `object` | Optional |
| [requests](#specdistributionmodulesmonitoringprometheusresourcesrequests) | `object` | Optional |

## .spec.distribution.modules.monitoring.prometheus.resources.limits

### Properties

| Property                                                                    | Type     | Required |
|:----------------------------------------------------------------------------|:---------|:---------|
| [cpu](#specdistributionmodulesmonitoringprometheusresourceslimitscpu)       | `string` | Optional |
| [memory](#specdistributionmodulesmonitoringprometheusresourceslimitsmemory) | `string` | Optional |

## .spec.distribution.modules.monitoring.prometheus.resources.limits.cpu

### Description

The CPU limit for the Pod. Example: `1000m`.

## .spec.distribution.modules.monitoring.prometheus.resources.limits.memory

### Description

The memory limit for the Pod. Example: `1G`.

## .spec.distribution.modules.monitoring.prometheus.resources.requests

### Properties

| Property                                                                      | Type     | Required |
|:------------------------------------------------------------------------------|:---------|:---------|
| [cpu](#specdistributionmodulesmonitoringprometheusresourcesrequestscpu)       | `string` | Optional |
| [memory](#specdistributionmodulesmonitoringprometheusresourcesrequestsmemory) | `string` | Optional |

## .spec.distribution.modules.monitoring.prometheus.resources.requests.cpu

### Description

The CPU request for the Pod, in cores. Example: `500m`.

## .spec.distribution.modules.monitoring.prometheus.resources.requests.memory

### Description

The memory request for the Pod. Example: `500M`.

## .spec.distribution.modules.monitoring.prometheus.retentionSize

### Description

The retention size for the `k8s` Prometheus instance.

## .spec.distribution.modules.monitoring.prometheus.retentionTime

### Description

The retention time for the `k8s` Prometheus instance.

## .spec.distribution.modules.monitoring.prometheus.storageSize

### Description

The storage size for the `k8s` Prometheus instance.

## .spec.distribution.modules.monitoring.prometheusAdapter

### Properties

| Property                                                                                                  | Type      | Required |
|:----------------------------------------------------------------------------------------------------------|:----------|:---------|
| [installEnhancedHPAMetrics](#specdistributionmodulesmonitoringprometheusadapterinstallenhancedhpametrics) | `boolean` | Optional |
| [resources](#specdistributionmodulesmonitoringprometheusadapterresources)                                 | `object`  | Optional |

## .spec.distribution.modules.monitoring.prometheusAdapter.installEnhancedHPAMetrics

### Description

Configures whether to enable advanced HPA metric collection in the Prometheus Adapter. When set to `true`, the Prometheus Adapter component will query Prometheus instances directly to retrieve additional metrics related to the Horizontal Pod Autoscaler (HPA). These metrics provide deeper visibility into HPA behaviour and performance. **Caution:** Enabling this feature results in a significant increase in RAM consumption of the Prometheus Adapter, as it requires managing an additional dataset. Default value: true.

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

The CPU limit for the Pod. Example: `1000m`.

## .spec.distribution.modules.monitoring.prometheusAdapter.resources.limits.memory

### Description

The memory limit for the Pod. Example: `1G`.

## .spec.distribution.modules.monitoring.prometheusAdapter.resources.requests

### Properties

| Property                                                                             | Type     | Required |
|:-------------------------------------------------------------------------------------|:---------|:---------|
| [cpu](#specdistributionmodulesmonitoringprometheusadapterresourcesrequestscpu)       | `string` | Optional |
| [memory](#specdistributionmodulesmonitoringprometheusadapterresourcesrequestsmemory) | `string` | Optional |

## .spec.distribution.modules.monitoring.prometheusAdapter.resources.requests.cpu

### Description

The CPU request for the Pod, in cores. Example: `500m`.

## .spec.distribution.modules.monitoring.prometheusAdapter.resources.requests.memory

### Description

The memory request for the Pod. Example: `500M`.

## .spec.distribution.modules.monitoring.prometheusAgent

### Properties

| Property                                                                    | Type     | Required |
|:----------------------------------------------------------------------------|:---------|:---------|
| [remoteWrite](#specdistributionmodulesmonitoringprometheusagentremotewrite) | `array`  | Optional |
| [resources](#specdistributionmodulesmonitoringprometheusagentresources)     | `object` | Optional |

## .spec.distribution.modules.monitoring.prometheusAgent.remoteWrite

### Description

Set this option to ship the collected metrics to a remote Prometheus receiver.

`remoteWrite` is an array of objects that allows configuring the [remoteWrite](https://prometheus.io/docs/specs/remote_write_spec/) options for Prometheus. The objects in the array follow [the same schema as in the prometheus operator](https://prometheus-operator.dev/docs/operator/api/#monitoring.coreos.com/v1.RemoteWriteSpec).

## .spec.distribution.modules.monitoring.prometheusAgent.resources

### Properties

| Property                                                                       | Type     | Required |
|:-------------------------------------------------------------------------------|:---------|:---------|
| [limits](#specdistributionmodulesmonitoringprometheusagentresourceslimits)     | `object` | Optional |
| [requests](#specdistributionmodulesmonitoringprometheusagentresourcesrequests) | `object` | Optional |

## .spec.distribution.modules.monitoring.prometheusAgent.resources.limits

### Properties

| Property                                                                         | Type     | Required |
|:---------------------------------------------------------------------------------|:---------|:---------|
| [cpu](#specdistributionmodulesmonitoringprometheusagentresourceslimitscpu)       | `string` | Optional |
| [memory](#specdistributionmodulesmonitoringprometheusagentresourceslimitsmemory) | `string` | Optional |

## .spec.distribution.modules.monitoring.prometheusAgent.resources.limits.cpu

### Description

The CPU limit for the Pod. Example: `1000m`.

## .spec.distribution.modules.monitoring.prometheusAgent.resources.limits.memory

### Description

The memory limit for the Pod. Example: `1G`.

## .spec.distribution.modules.monitoring.prometheusAgent.resources.requests

### Properties

| Property                                                                           | Type     | Required |
|:-----------------------------------------------------------------------------------|:---------|:---------|
| [cpu](#specdistributionmodulesmonitoringprometheusagentresourcesrequestscpu)       | `string` | Optional |
| [memory](#specdistributionmodulesmonitoringprometheusagentresourcesrequestsmemory) | `string` | Optional |

## .spec.distribution.modules.monitoring.prometheusAgent.resources.requests.cpu

### Description

The CPU request for the Pod, in cores. Example: `500m`.

## .spec.distribution.modules.monitoring.prometheusAgent.resources.requests.memory

### Description

The memory request for the Pod. Example: `500M`.

## .spec.distribution.modules.monitoring.type

### Description

The type of the monitoring, must be `none`, `prometheus`, `prometheusAgent` or `mimir`.

- `none`: will disable the whole monitoring stack.
- `prometheus`: will install Prometheus Operator and a preconfigured Prometheus instance, Alertmanager, a set of alert rules, exporters needed to monitor all the components of the cluster, Grafana and a series of dashboards to view the collected metrics, and more.
- `prometheusAgent`: will install Prometheus operator, an instance of Prometheus in Agent mode (no alerting, no queries, no storage), and all the exporters needed to get metrics for the status of the cluster and the workloads. Useful when having a centralized (remote) Prometheus where to ship the metrics and not storing them locally in the cluster.
- `mimir`: will install the same as the `prometheus` option, plus Grafana Mimir that allows for longer retention of metrics and the usage of Object Storage.

Default is `prometheus`.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value             |
|:------------------|
|`"none"`           |
|`"prometheus"`     |
|`"prometheusAgent"`|
|`"mimir"`          |

## .spec.distribution.modules.monitoring.x509Exporter

### Properties

| Property                                                             | Type     | Required |
|:---------------------------------------------------------------------|:---------|:---------|
| [overrides](#specdistributionmodulesmonitoringx509exporteroverrides) | `object` | Optional |

## .spec.distribution.modules.monitoring.x509Exporter.overrides

### Properties

| Property                                                                            | Type     | Required |
|:------------------------------------------------------------------------------------|:---------|:---------|
| [nodeSelector](#specdistributionmodulesmonitoringx509exporteroverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulesmonitoringx509exporteroverridestolerations)   | `array`  | Optional |

## .spec.distribution.modules.monitoring.x509Exporter.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the package.

## .spec.distribution.modules.monitoring.x509Exporter.overrides.tolerations

### Properties

| Property                                                                               | Type     | Required |
|:---------------------------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulesmonitoringx509exporteroverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulesmonitoringx509exporteroverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulesmonitoringx509exporteroverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulesmonitoringx509exporteroverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the package.

## .spec.distribution.modules.monitoring.x509Exporter.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.monitoring.x509Exporter.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.monitoring.x509Exporter.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.monitoring.x509Exporter.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.networking

### Properties

| Property                                                           | Type     | Required |
|:-------------------------------------------------------------------|:---------|:---------|
| [cilium](#specdistributionmodulesnetworkingcilium)                 | `object` | Optional |
| [overrides](#specdistributionmodulesnetworkingoverrides)           | `object` | Optional |
| [tigeraOperator](#specdistributionmodulesnetworkingtigeraoperator) | `object` | Optional |
| [type](#specdistributionmodulesnetworkingtype)                     | `string` | Required |

### Description

Configuration for the Networking module.

## .spec.distribution.modules.networking.cilium

### Properties

| Property                                                       | Type     | Required |
|:---------------------------------------------------------------|:---------|:---------|
| [maskSize](#specdistributionmodulesnetworkingciliummasksize)   | `string` | Optional |
| [overrides](#specdistributionmodulesnetworkingciliumoverrides) | `object` | Optional |
| [podCidr](#specdistributionmodulesnetworkingciliumpodcidr)     | `string` | Optional |

## .spec.distribution.modules.networking.cilium.maskSize

### Description

The mask size to use for the Pods network on each node.

## .spec.distribution.modules.networking.cilium.overrides

### Properties

| Property                                                                      | Type     | Required |
|:------------------------------------------------------------------------------|:---------|:---------|
| [nodeSelector](#specdistributionmodulesnetworkingciliumoverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulesnetworkingciliumoverridestolerations)   | `array`  | Optional |

## .spec.distribution.modules.networking.cilium.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the package.

## .spec.distribution.modules.networking.cilium.overrides.tolerations

### Properties

| Property                                                                         | Type     | Required |
|:---------------------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulesnetworkingciliumoverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulesnetworkingciliumoverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulesnetworkingciliumoverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulesnetworkingciliumoverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the package.

## .spec.distribution.modules.networking.cilium.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.networking.cilium.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.networking.cilium.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.networking.cilium.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.networking.cilium.podCidr

### Description

Allows specifing a CIDR for the Pods network different from `.spec.kubernetes.podCidr`. If not set the default is to use `.spec.kubernetes.podCidr`.

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}\/(3[0-2]|[1-2][0-9]|[0-9])$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.?\b\){4}\\/\(3[0-2]|[1-2][0-9]|[0-9]\)$)

## .spec.distribution.modules.networking.overrides

### Properties

| Property                                                                | Type     | Required |
|:------------------------------------------------------------------------|:---------|:---------|
| [ingresses](#specdistributionmodulesnetworkingoverridesingresses)       | `object` | Optional |
| [nodeSelector](#specdistributionmodulesnetworkingoverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulesnetworkingoverridestolerations)   | `array`  | Optional |

### Description

Override the common configuration with a particular configuration for the module.

## .spec.distribution.modules.networking.overrides.ingresses

## .spec.distribution.modules.networking.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the module.

## .spec.distribution.modules.networking.overrides.tolerations

### Properties

| Property                                                                   | Type     | Required |
|:---------------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulesnetworkingoverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulesnetworkingoverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulesnetworkingoverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulesnetworkingoverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the module.

## .spec.distribution.modules.networking.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.networking.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.networking.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.networking.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.networking.tigeraOperator

### Properties

| Property                                                               | Type      | Required |
|:-----------------------------------------------------------------------|:----------|:---------|
| [blockSize](#specdistributionmodulesnetworkingtigeraoperatorblocksize) | `integer` | Optional |
| [overrides](#specdistributionmodulesnetworkingtigeraoperatoroverrides) | `object`  | Optional |
| [podCidr](#specdistributionmodulesnetworkingtigeraoperatorpodcidr)     | `string`  | Optional |

## .spec.distribution.modules.networking.tigeraOperator.blockSize

### Description

BlockSize specifies the CIDR prefex length to use when allocating per-node IP blocks from the main IP pool CIDR.

## .spec.distribution.modules.networking.tigeraOperator.overrides

### Properties

| Property                                                                              | Type     | Required |
|:--------------------------------------------------------------------------------------|:---------|:---------|
| [nodeSelector](#specdistributionmodulesnetworkingtigeraoperatoroverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulesnetworkingtigeraoperatoroverridestolerations)   | `array`  | Optional |

## .spec.distribution.modules.networking.tigeraOperator.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the package.

## .spec.distribution.modules.networking.tigeraOperator.overrides.tolerations

### Properties

| Property                                                                                 | Type     | Required |
|:-----------------------------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulesnetworkingtigeraoperatoroverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulesnetworkingtigeraoperatoroverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulesnetworkingtigeraoperatoroverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulesnetworkingtigeraoperatoroverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the package.

## .spec.distribution.modules.networking.tigeraOperator.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.networking.tigeraOperator.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.networking.tigeraOperator.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.networking.tigeraOperator.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.networking.tigeraOperator.podCidr

### Description

Allows specifing a CIDR for the Pods network different from `.spec.kubernetes.podCidr`. If not set the default is to use `.spec.kubernetes.podCidr`.

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}\/(3[0-2]|[1-2][0-9]|[0-9])$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.?\b\){4}\\/\(3[0-2]|[1-2][0-9]|[0-9]\)$)

## .spec.distribution.modules.networking.type

### Description

The type of CNI plugin to use, either `calico` (Tigera Operator) or `cilium`. Default is `calico`.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"calico"`|
|`"cilium"`|

## .spec.distribution.modules.policy

### Properties

| Property                                               | Type     | Required |
|:-------------------------------------------------------|:---------|:---------|
| [gatekeeper](#specdistributionmodulespolicygatekeeper) | `object` | Optional |
| [kyverno](#specdistributionmodulespolicykyverno)       | `object` | Optional |
| [overrides](#specdistributionmodulespolicyoverrides)   | `object` | Optional |
| [type](#specdistributionmodulespolicytype)             | `string` | Required |

### Description

Configuration for the Policy module.

## .spec.distribution.modules.policy.gatekeeper

### Properties

| Property                                                                                             | Type      | Required |
|:-----------------------------------------------------------------------------------------------------|:----------|:---------|
| [additionalExcludedNamespaces](#specdistributionmodulespolicygatekeeperadditionalexcludednamespaces) | `array`   | Optional |
| [enforcementAction](#specdistributionmodulespolicygatekeeperenforcementaction)                       | `string`  | Required |
| [installDefaultPolicies](#specdistributionmodulespolicygatekeeperinstalldefaultpolicies)             | `boolean` | Required |
| [overrides](#specdistributionmodulespolicygatekeeperoverrides)                                       | `object`  | Optional |

### Description

Configuration for the Gatekeeper package.

## .spec.distribution.modules.policy.gatekeeper.additionalExcludedNamespaces

### Description

This parameter adds namespaces to Gatekeeper's exemption list, so it will not enforce the constraints on them.

## .spec.distribution.modules.policy.gatekeeper.enforcementAction

### Description

The default enforcement action to use for the included constraints. `deny` will block the admission when violations to the policies are found, `warn` will show a message to the user but will admit the violating requests and `dryrun` won't give any feedback to the user but it will log the violations.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"deny"`  |
|`"dryrun"`|
|`"warn"`  |

## .spec.distribution.modules.policy.gatekeeper.installDefaultPolicies

### Description

Set to `false` to avoid installing the default Gatekeeper policies (constraints templates and constraints) included with the distribution.

## .spec.distribution.modules.policy.gatekeeper.overrides

### Properties

| Property                                                                      | Type     | Required |
|:------------------------------------------------------------------------------|:---------|:---------|
| [nodeSelector](#specdistributionmodulespolicygatekeeperoverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulespolicygatekeeperoverridestolerations)   | `array`  | Optional |

## .spec.distribution.modules.policy.gatekeeper.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the package.

## .spec.distribution.modules.policy.gatekeeper.overrides.tolerations

### Properties

| Property                                                                         | Type     | Required |
|:---------------------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulespolicygatekeeperoverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulespolicygatekeeperoverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulespolicygatekeeperoverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulespolicygatekeeperoverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the package.

## .spec.distribution.modules.policy.gatekeeper.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.policy.gatekeeper.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.policy.gatekeeper.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.policy.gatekeeper.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.policy.kyverno

### Properties

| Property                                                                                          | Type      | Required |
|:--------------------------------------------------------------------------------------------------|:----------|:---------|
| [additionalExcludedNamespaces](#specdistributionmodulespolicykyvernoadditionalexcludednamespaces) | `array`   | Optional |
| [installDefaultPolicies](#specdistributionmodulespolicykyvernoinstalldefaultpolicies)             | `boolean` | Required |
| [overrides](#specdistributionmodulespolicykyvernooverrides)                                       | `object`  | Optional |
| [validationFailureAction](#specdistributionmodulespolicykyvernovalidationfailureaction)           | `string`  | Required |

### Description

Configuration for the Kyverno package.

## .spec.distribution.modules.policy.kyverno.additionalExcludedNamespaces

### Description

This parameter adds namespaces to Kyverno's exemption list, so it will not enforce the policies on them.

## .spec.distribution.modules.policy.kyverno.installDefaultPolicies

### Description

Set to `false` to avoid installing the default Kyverno policies included with distribution.

## .spec.distribution.modules.policy.kyverno.overrides

### Properties

| Property                                                                   | Type     | Required |
|:---------------------------------------------------------------------------|:---------|:---------|
| [nodeSelector](#specdistributionmodulespolicykyvernooverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulespolicykyvernooverridestolerations)   | `array`  | Optional |

## .spec.distribution.modules.policy.kyverno.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the package.

## .spec.distribution.modules.policy.kyverno.overrides.tolerations

### Properties

| Property                                                                      | Type     | Required |
|:------------------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulespolicykyvernooverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulespolicykyvernooverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulespolicykyvernooverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulespolicykyvernooverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the package.

## .spec.distribution.modules.policy.kyverno.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.policy.kyverno.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.policy.kyverno.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.policy.kyverno.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.policy.kyverno.validationFailureAction

### Description

The validation failure action to use for the included policies, `Enforce` will block when a request does not comply with the policies and `Audit` will not block but log when a request does not comply with the policies.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value     |
|:----------|
|`"Audit"`  |
|`"Enforce"`|

## .spec.distribution.modules.policy.overrides

### Properties

| Property                                                            | Type     | Required |
|:--------------------------------------------------------------------|:---------|:---------|
| [ingresses](#specdistributionmodulespolicyoverridesingresses)       | `object` | Optional |
| [nodeSelector](#specdistributionmodulespolicyoverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulespolicyoverridestolerations)   | `array`  | Optional |

### Description

Override the common configuration with a particular configuration for the module.

## .spec.distribution.modules.policy.overrides.ingresses

## .spec.distribution.modules.policy.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the module.

## .spec.distribution.modules.policy.overrides.tolerations

### Properties

| Property                                                               | Type     | Required |
|:-----------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulespolicyoverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulespolicyoverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulespolicyoverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulespolicyoverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the module.

## .spec.distribution.modules.policy.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.policy.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.policy.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.policy.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.policy.type

### Description

The type of policy enforcement to use, either `none`, `gatekeeper` or `kyverno`.

Default is `none`.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value        |
|:-------------|
|`"none"`      |
|`"gatekeeper"`|
|`"kyverno"`   |

## .spec.distribution.modules.tracing

### Properties

| Property                                              | Type     | Required |
|:------------------------------------------------------|:---------|:---------|
| [minio](#specdistributionmodulestracingminio)         | `object` | Optional |
| [overrides](#specdistributionmodulestracingoverrides) | `object` | Optional |
| [tempo](#specdistributionmodulestracingtempo)         | `object` | Optional |
| [type](#specdistributionmodulestracingtype)           | `string` | Required |

### Description

Configuration for the Tracing module.

## .spec.distribution.modules.tracing.minio

### Properties

| Property                                                       | Type     | Required |
|:---------------------------------------------------------------|:---------|:---------|
| [overrides](#specdistributionmodulestracingminiooverrides)     | `object` | Optional |
| [rootUser](#specdistributionmodulestracingminiorootuser)       | `object` | Optional |
| [storageSize](#specdistributionmodulestracingminiostoragesize) | `string` | Optional |

### Description

Configuration for Tracing's MinIO deployment.

## .spec.distribution.modules.tracing.minio.overrides

### Properties

| Property                                                                  | Type     | Required |
|:--------------------------------------------------------------------------|:---------|:---------|
| [nodeSelector](#specdistributionmodulestracingminiooverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulestracingminiooverridestolerations)   | `array`  | Optional |

## .spec.distribution.modules.tracing.minio.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the package.

## .spec.distribution.modules.tracing.minio.overrides.tolerations

### Properties

| Property                                                                     | Type     | Required |
|:-----------------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulestracingminiooverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulestracingminiooverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulestracingminiooverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulestracingminiooverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the package.

## .spec.distribution.modules.tracing.minio.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.tracing.minio.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.tracing.minio.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.tracing.minio.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.tracing.minio.rootUser

### Properties

| Property                                                         | Type     | Required |
|:-----------------------------------------------------------------|:---------|:---------|
| [password](#specdistributionmodulestracingminiorootuserpassword) | `string` | Optional |
| [username](#specdistributionmodulestracingminiorootuserusername) | `string` | Optional |

## .spec.distribution.modules.tracing.minio.rootUser.password

### Description

The password for the default MinIO root user.

## .spec.distribution.modules.tracing.minio.rootUser.username

### Description

The username for the default MinIO root user.

## .spec.distribution.modules.tracing.minio.storageSize

### Description

The PVC size for each MinIO disk, 6 disks total.

## .spec.distribution.modules.tracing.overrides

### Properties

| Property                                                             | Type     | Required |
|:---------------------------------------------------------------------|:---------|:---------|
| [ingresses](#specdistributionmodulestracingoverridesingresses)       | `object` | Optional |
| [nodeSelector](#specdistributionmodulestracingoverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulestracingoverridestolerations)   | `array`  | Optional |

### Description

Override the common configuration with a particular configuration for the module.

## .spec.distribution.modules.tracing.overrides.ingresses

## .spec.distribution.modules.tracing.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the module.

## .spec.distribution.modules.tracing.overrides.tolerations

### Properties

| Property                                                                | Type     | Required |
|:------------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulestracingoverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulestracingoverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulestracingoverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulestracingoverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the module.

## .spec.distribution.modules.tracing.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.tracing.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.tracing.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.tracing.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.tracing.tempo

### Properties

| Property                                                                 | Type     | Required |
|:-------------------------------------------------------------------------|:---------|:---------|
| [backend](#specdistributionmodulestracingtempobackend)                   | `string` | Optional |
| [externalEndpoint](#specdistributionmodulestracingtempoexternalendpoint) | `object` | Optional |
| [overrides](#specdistributionmodulestracingtempooverrides)               | `object` | Optional |
| [retentionTime](#specdistributionmodulestracingtemporetentiontime)       | `string` | Optional |

### Description

Configuration for the Tempo package.

## .spec.distribution.modules.tracing.tempo.backend

### Description

The storage backend type for Tempo. `minio` will use an in-cluster MinIO deployment for object storage, `externalEndpoint` can be used to point to an external S3-compatible object storage instead of deploying an in-cluster MinIO.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"minio"`           |
|`"externalEndpoint"`|

## .spec.distribution.modules.tracing.tempo.externalEndpoint

### Properties

| Property                                                                               | Type      | Required |
|:---------------------------------------------------------------------------------------|:----------|:---------|
| [accessKeyId](#specdistributionmodulestracingtempoexternalendpointaccesskeyid)         | `string`  | Optional |
| [bucketName](#specdistributionmodulestracingtempoexternalendpointbucketname)           | `string`  | Optional |
| [endpoint](#specdistributionmodulestracingtempoexternalendpointendpoint)               | `string`  | Optional |
| [insecure](#specdistributionmodulestracingtempoexternalendpointinsecure)               | `boolean` | Optional |
| [secretAccessKey](#specdistributionmodulestracingtempoexternalendpointsecretaccesskey) | `string`  | Optional |

### Description

Configuration for Tempo's external storage backend.

## .spec.distribution.modules.tracing.tempo.externalEndpoint.accessKeyId

### Description

The access key ID (username) for the external S3-compatible bucket.

## .spec.distribution.modules.tracing.tempo.externalEndpoint.bucketName

### Description

The bucket name of the external S3-compatible object storage.

## .spec.distribution.modules.tracing.tempo.externalEndpoint.endpoint

### Description

The external S3-compatible endpoint for Tempo's storage.

## .spec.distribution.modules.tracing.tempo.externalEndpoint.insecure

### Description

If true, will use HTTP as protocol instead of HTTPS.

## .spec.distribution.modules.tracing.tempo.externalEndpoint.secretAccessKey

### Description

The secret access key (password) for the external S3-compatible bucket.

## .spec.distribution.modules.tracing.tempo.overrides

### Properties

| Property                                                                  | Type     | Required |
|:--------------------------------------------------------------------------|:---------|:---------|
| [nodeSelector](#specdistributionmodulestracingtempooverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulestracingtempooverridestolerations)   | `array`  | Optional |

## .spec.distribution.modules.tracing.tempo.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the package.

## .spec.distribution.modules.tracing.tempo.overrides.tolerations

### Properties

| Property                                                                     | Type     | Required |
|:-----------------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulestracingtempooverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulestracingtempooverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulestracingtempooverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulestracingtempooverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the package.

## .spec.distribution.modules.tracing.tempo.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.tracing.tempo.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.tracing.tempo.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.tracing.tempo.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.tracing.tempo.retentionTime

### Description

The retention time for the traces stored in Tempo.

## .spec.distribution.modules.tracing.type

### Description

The type of tracing to use, either `none` or `tempo`. `none` will disable the Tracing module and `tempo` will install a Grafana Tempo deployment.

Default is `tempo`.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value   |
|:--------|
|`"none"` |
|`"tempo"`|

## .spec.distributionVersion

### Description

Defines which KFD version will be installed and, in consequence, the Kubernetes version used to create the cluster. It supports git tags and branches. Example: `v1.30.1`.

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.kubernetes

### Properties

| Property                                                  | Type     | Required |
|:----------------------------------------------------------|:---------|:---------|
| [advanced](#speckubernetesadvanced)                       | `object` | Optional |
| [advancedAnsible](#speckubernetesadvancedansible)         | `object` | Optional |
| [controlPlaneAddress](#speckubernetescontrolplaneaddress) | `string` | Required |
| [dnsZone](#speckubernetesdnszone)                         | `string` | Required |
| [etcd](#speckubernetesetcd)                               | `object` | Optional |
| [loadBalancers](#speckubernetesloadbalancers)             | `object` | Required |
| [masters](#speckubernetesmasters)                         | `object` | Required |
| [nodes](#speckubernetesnodes)                             | `array`  | Required |
| [pkiFolder](#speckubernetespkifolder)                     | `string` | Required |
| [podCidr](#speckubernetespodcidr)                         | `string` | Required |
| [proxy](#speckubernetesproxy)                             | `object` | Optional |
| [ssh](#speckubernetesssh)                                 | `object` | Required |
| [svcCidr](#speckubernetessvccidr)                         | `string` | Required |

### Description

Defines the Kubernetes components configuration and the values needed for the kubernetes phase of furyctl.

## .spec.kubernetes.advanced

### Properties

| Property                                                            | Type     | Required |
|:--------------------------------------------------------------------|:---------|:---------|
| [airGap](#speckubernetesadvancedairgap)                             | `object` | Optional |
| [apiServerCertSANs](#speckubernetesadvancedapiservercertsans)       | `array`  | Optional |
| [cloud](#speckubernetesadvancedcloud)                               | `object` | Optional |
| [containerd](#speckubernetesadvancedcontainerd)                     | `object` | Optional |
| [encryption](#speckubernetesadvancedencryption)                     | `object` | Optional |
| [kubeletConfiguration](#speckubernetesadvancedkubeletconfiguration) | `object` | Optional |
| [oidc](#speckubernetesadvancedoidc)                                 | `object` | Optional |
| [registry](#speckubernetesadvancedregistry)                         | `string` | Optional |
| [users](#speckubernetesadvancedusers)                               | `object` | Optional |

## .spec.kubernetes.advanced.airGap

### Properties

| Property                                                                    | Type     | Required |
|:----------------------------------------------------------------------------|:---------|:---------|
| [containerdDownloadUrl](#speckubernetesadvancedairgapcontainerddownloadurl) | `string` | Optional |
| [dependenciesOverride](#speckubernetesadvancedairgapdependenciesoverride)   | `object` | Optional |
| [etcdDownloadUrl](#speckubernetesadvancedairgapetcddownloadurl)             | `string` | Optional |
| [runcChecksum](#speckubernetesadvancedairgapruncchecksum)                   | `string` | Optional |
| [runcDownloadUrl](#speckubernetesadvancedairgapruncdownloadurl)             | `string` | Optional |

### Description

Advanced configuration for air-gapped installations. Allows setting custom URLs where to download the binaries dependencies from and custom .deb and .rpm package repositories.

## .spec.kubernetes.advanced.airGap.containerdDownloadUrl

### Description

URL where to download the `.tar.gz` with containerd from. The `tar.gz` should be as the one downloaded from containerd GitHub releases page.

## .spec.kubernetes.advanced.airGap.dependenciesOverride

### Properties

| Property                                                    | Type     | Required |
|:------------------------------------------------------------|:---------|:---------|
| [apt](#speckubernetesadvancedairgapdependenciesoverrideapt) | `object` | Optional |
| [yum](#speckubernetesadvancedairgapdependenciesoverrideyum) | `object` | Optional |

## .spec.kubernetes.advanced.airGap.dependenciesOverride.apt

### Properties

| Property                                                                     | Type     | Required |
|:-----------------------------------------------------------------------------|:---------|:---------|
| [gpg_key](#speckubernetesadvancedairgapdependenciesoverrideaptgpg_key)       | `string` | Required |
| [gpg_key_id](#speckubernetesadvancedairgapdependenciesoverrideaptgpg_key_id) | `string` | Required |
| [name](#speckubernetesadvancedairgapdependenciesoverrideaptname)             | `string` | Required |
| [repo](#speckubernetesadvancedairgapdependenciesoverrideaptrepo)             | `string` | Required |

## .spec.kubernetes.advanced.airGap.dependenciesOverride.apt.gpg_key

### Description

URL where to download the GPG key of the Apt repository. Example: `https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key`

## .spec.kubernetes.advanced.airGap.dependenciesOverride.apt.gpg_key_id

### Description

The GPG key ID of the Apt repository. Example: `36A1D7869245C8950F966E92D8576A8BA88D21E9`

## .spec.kubernetes.advanced.airGap.dependenciesOverride.apt.name

### Description

An indicative name for the Apt repository. Example: `k8s-1.29`

## .spec.kubernetes.advanced.airGap.dependenciesOverride.apt.repo

### Description

A source string for the new Apt repository. Example: `deb https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /`

## .spec.kubernetes.advanced.airGap.dependenciesOverride.yum

### Properties

| Property                                                                             | Type      | Required |
|:-------------------------------------------------------------------------------------|:----------|:---------|
| [gpg_key](#speckubernetesadvancedairgapdependenciesoverrideyumgpg_key)               | `string`  | Required |
| [gpg_key_check](#speckubernetesadvancedairgapdependenciesoverrideyumgpg_key_check)   | `boolean` | Required |
| [name](#speckubernetesadvancedairgapdependenciesoverrideyumname)                     | `string`  | Required |
| [repo](#speckubernetesadvancedairgapdependenciesoverrideyumrepo)                     | `string`  | Required |
| [repo_gpg_check](#speckubernetesadvancedairgapdependenciesoverrideyumrepo_gpg_check) | `boolean` | Required |

## .spec.kubernetes.advanced.airGap.dependenciesOverride.yum.gpg_key

### Description

URL where to download the ASCII-armored GPG key of the Yum repository. Example: `https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key`

## .spec.kubernetes.advanced.airGap.dependenciesOverride.yum.gpg_key_check

### Description

If true, the GPG signature check on the packages will be enabled.

## .spec.kubernetes.advanced.airGap.dependenciesOverride.yum.name

### Description

An indicative name for the Yum repository. Example: `k8s-1.29`

## .spec.kubernetes.advanced.airGap.dependenciesOverride.yum.repo

### Description

URL to the directory where the Yum repository's `repodata` directory lives. Example: `https://pkgs.k8s.io/core:/stable:/v1.29/rpm/`

## .spec.kubernetes.advanced.airGap.dependenciesOverride.yum.repo_gpg_check

### Description

If true, the GPG signature check on the `repodata` will be enabled.

## .spec.kubernetes.advanced.airGap.etcdDownloadUrl

### Description

URL to the path where the etcd `tar.gz`s are available. etcd will be downloaded from `<etcdDownloadUrl>/<etcd_version>/etcd-<etcd_version>-linux-<host_architecture>.tar.gz`

## .spec.kubernetes.advanced.airGap.runcChecksum

### Description

Checksum for the runc binary.

## .spec.kubernetes.advanced.airGap.runcDownloadUrl

### Description

URL where to download the runc binary from.

## .spec.kubernetes.advanced.apiServerCertSANs

### Description

Additional Subject Alternative Names for the API server certificates. These are used to secure connections to the API server from various clients.

## .spec.kubernetes.advanced.cloud

### Properties

| Property                                         | Type     | Required |
|:-------------------------------------------------|:---------|:---------|
| [config](#speckubernetesadvancedcloudconfig)     | `string` | Optional |
| [provider](#speckubernetesadvancedcloudprovider) | `string` | Optional |

## .spec.kubernetes.advanced.cloud.config

### Description

Sets cloud config for the Kubelet

## .spec.kubernetes.advanced.cloud.provider

### Description

Sets the cloud provider for the Kubelet

## .spec.kubernetes.advanced.containerd

### Properties

| Property                                                            | Type    | Required |
|:--------------------------------------------------------------------|:--------|:---------|
| [registryConfigs](#speckubernetesadvancedcontainerdregistryconfigs) | `array` | Optional |

### Description

Advanced configuration for containerd

## .spec.kubernetes.advanced.containerd.registryConfigs

### Properties

| Property                                                                                 | Type      | Required |
|:-----------------------------------------------------------------------------------------|:----------|:---------|
| [insecureSkipVerify](#speckubernetesadvancedcontainerdregistryconfigsinsecureskipverify) | `boolean` | Optional |
| [mirrorEndpoint](#speckubernetesadvancedcontainerdregistryconfigsmirrorendpoint)         | `array`   | Optional |
| [password](#speckubernetesadvancedcontainerdregistryconfigspassword)                     | `string`  | Optional |
| [registry](#speckubernetesadvancedcontainerdregistryconfigsregistry)                     | `string`  | Optional |
| [username](#speckubernetesadvancedcontainerdregistryconfigsusername)                     | `string`  | Optional |

### Description

Allows specifying custom configuration for a registry at containerd level. You can set authentication details and mirrors for a registry.
This feature can be used for example to authenticate to a private registry at containerd (container runtime) level, i.e. globally instead of using `imagePullSecrets`. It also can be used to use a mirror for a registry or to enable insecure connections to trusted registries that have self-signed certificates.

## .spec.kubernetes.advanced.containerd.registryConfigs.insecureSkipVerify

### Description

Set to `true` to skip TLS verification (e.g. when using self-signed certificates).

## .spec.kubernetes.advanced.containerd.registryConfigs.mirrorEndpoint

### Description

Array of URLs with the mirrors to use for the registry. Example: `["http://mymirror.tld:8080"]`

## .spec.kubernetes.advanced.containerd.registryConfigs.password

### Description

The password containerd will use to authenticate against the registry.

## .spec.kubernetes.advanced.containerd.registryConfigs.registry

### Description

Registry address on which you would like to configure authentication or mirror(s). Example: `myregistry.tld:5000`

## .spec.kubernetes.advanced.containerd.registryConfigs.username

### Description

The username containerd will use to authenticate against the registry.

## .spec.kubernetes.advanced.encryption

### Properties

| Property                                                            | Type     | Required |
|:--------------------------------------------------------------------|:---------|:---------|
| [configuration](#speckubernetesadvancedencryptionconfiguration)     | `string` | Optional |
| [tlsCipherSuites](#speckubernetesadvancedencryptiontlsciphersuites) | `array`  | Optional |

## .spec.kubernetes.advanced.encryption.configuration

### Description

etcd's encryption at rest configuration. Must be a string with the EncryptionConfiguration object in YAML. Example:

```yaml

apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
    - secrets
    providers:
    - aescbc:
        keys:
        - name: mykey
          secret: base64_encoded_secret
```


## .spec.kubernetes.advanced.encryption.tlsCipherSuites

### Description

The TLS cipher suites to use for etcd, kubelet, and kubeadm static pods. Example:
```yaml
tlsCipherSuites:
  - "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
  - "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
  - "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384"
  - "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
  - "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256"
  - "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256"
  - "TLS_AES_128_GCM_SHA256"
  - "TLS_AES_256_GCM_SHA384"
  - "TLS_CHACHA20_POLY1305_SHA256"
```
. NOTE: to customize the TLS cipher suites of the kubelet (as well as on control plane and etcd), set only this field - do not configure them under the `KubeletConfiguration`.

## .spec.kubernetes.advanced.kubeletConfiguration

### Description

Advanced configuration for Kubelet. This open field allows users to specify any parameter supported by the `KubeletConfiguration` object. Examples of uses include controlling the maximum number of pods per core (`podsPerCore`), managing container logging (`containerLogMaxSize`), Topology Manager options (`topologyManagerPolicyOptions`). All values must follow the official Kubelet specification: https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/.

NOTE: Content will **not** be validated by furyctl. To customize the TLS cipher suites of the Kubelet, set only the `Spec.Kubernetes.Advanced.Encryption.tlsCipherSuites` field - do not configure them under this field.

## .spec.kubernetes.advanced.oidc

### Properties

| Property                                                      | Type     | Required |
|:--------------------------------------------------------------|:---------|:---------|
| [ca_file](#speckubernetesadvancedoidcca_file)                 | `string` | Optional |
| [client_id](#speckubernetesadvancedoidcclient_id)             | `string` | Optional |
| [group_prefix](#speckubernetesadvancedoidcgroup_prefix)       | `string` | Optional |
| [groups_claim](#speckubernetesadvancedoidcgroups_claim)       | `string` | Optional |
| [issuer_url](#speckubernetesadvancedoidcissuer_url)           | `string` | Optional |
| [username_claim](#speckubernetesadvancedoidcusername_claim)   | `string` | Optional |
| [username_prefix](#speckubernetesadvancedoidcusername_prefix) | `string` | Optional |

### Description

OIDC configuration for the Kubernetes API server.

## .spec.kubernetes.advanced.oidc.ca_file

### Description

The path to the certificate for the CA that signed the identity provider's web certificate. Defaults to the host's root CAs. This should be a path available to the API Server.

## .spec.kubernetes.advanced.oidc.client_id

### Description

The client ID the API server will use to authenticate to the OIDC provider.

## .spec.kubernetes.advanced.oidc.group_prefix

### Description

Prefix prepended to group claims to prevent clashes with existing names (such as system: groups).

## .spec.kubernetes.advanced.oidc.groups_claim

### Description

JWT claim to use as the user's group.

## .spec.kubernetes.advanced.oidc.issuer_url

### Description

The issuer URL of the OIDC provider.

## .spec.kubernetes.advanced.oidc.username_claim

### Description

JWT claim to use as the user name. The default value is `sub`, which is expected to be a unique identifier of the end user.

## .spec.kubernetes.advanced.oidc.username_prefix

### Description

Prefix prepended to username claims to prevent clashes with existing names (such as system: users).

## .spec.kubernetes.advanced.registry

### Description

URL of the registry where to pull images from for the Kubernetes phase. (Default is registry.sighup.io/fury/on-premises).

## .spec.kubernetes.advanced.users

### Properties

| Property                                   | Type     | Required |
|:-------------------------------------------|:---------|:---------|
| [names](#speckubernetesadvancedusersnames) | `array`  | Optional |
| [org](#speckubernetesadvancedusersorg)     | `string` | Optional |

## .spec.kubernetes.advanced.users.names

### Description

List of user names to create and get a kubeconfig file. Users will not have any permissions by default, RBAC setup for the new users is needed.

## .spec.kubernetes.advanced.users.org

### Description

The organization the users belong to.

## .spec.kubernetes.advancedAnsible

### Properties

| Property                                                             | Type     | Required |
|:---------------------------------------------------------------------|:---------|:---------|
| [config](#speckubernetesadvancedansibleconfig)                       | `string` | Optional |
| [pythonInterpreter](#speckubernetesadvancedansiblepythoninterpreter) | `string` | Optional |

## .spec.kubernetes.advancedAnsible.config

### Description

Additional configuration to append to the ansible.cfg file

## .spec.kubernetes.advancedAnsible.pythonInterpreter

### Description

The Python interpreter to use for running Ansible. Example: python3

## .spec.kubernetes.controlPlaneAddress

### Description

The address for the Kubernetes control plane. Usually a DNS entry pointing to a Load Balancer on port 6443.

## .spec.kubernetes.dnsZone

### Description

The DNS zone of the machines. It will be appended to the name of each host to generate the `kubernetes_hostname` in the Ansible inventory file. It is also used to calculate etcd's initial cluster value.

## .spec.kubernetes.etcd

### Properties

| Property                          | Type    | Required |
|:----------------------------------|:--------|:---------|
| [hosts](#speckubernetesetcdhosts) | `array` | Required |

### Description

Optional configuration for an etcd cluster on dedicated nodes. If omitted, etcd will run on control plane nodes.

## .spec.kubernetes.etcd.hosts

### Properties

| Property                             | Type     | Required |
|:-------------------------------------|:---------|:---------|
| [ip](#speckubernetesetcdhostsip)     | `string` | Required |
| [name](#speckubernetesetcdhostsname) | `string` | Required |

### Description

List of nodes of the dedicated etcd cluster.

### Constraints

**minimum number of items**: the minimum number of items for this array is: `1`

## .spec.kubernetes.etcd.hosts.ip

### Description

The IP address of the etcd node.

## .spec.kubernetes.etcd.hosts.name

### Description

A name to identify the etcd node. This value will be concatenated to `.spec.kubernetes.dnsZone` to calculate the FQDN for the host as `<name>.<dnsZone>`.

## .spec.kubernetes.loadBalancers

### Properties

| Property                                                         | Type      | Required |
|:-----------------------------------------------------------------|:----------|:---------|
| [additionalConfig](#speckubernetesloadbalancersadditionalconfig) | `string`  | Optional |
| [enabled](#speckubernetesloadbalancersenabled)                   | `boolean` | Required |
| [hosts](#speckubernetesloadbalancershosts)                       | `array`   | Optional |
| [keepalived](#speckubernetesloadbalancerskeepalived)             | `object`  | Optional |
| [stats](#speckubernetesloadbalancersstats)                       | `object`  | Optional |

## .spec.kubernetes.loadBalancers.additionalConfig

### Description

Additional configuration to append to HAProxy's configuration file.

## .spec.kubernetes.loadBalancers.enabled

### Description

Set to true to install HAProxy and configure it as a load balancer on the the load balancer hosts.

## .spec.kubernetes.loadBalancers.hosts

### Properties

| Property                                      | Type     | Required |
|:----------------------------------------------|:---------|:---------|
| [ip](#speckubernetesloadbalancershostsip)     | `string` | Required |
| [name](#speckubernetesloadbalancershostsname) | `string` | Required |

## .spec.kubernetes.loadBalancers.hosts.ip

### Description

The IP address of the host.

## .spec.kubernetes.loadBalancers.hosts.name

### Description

A name to identify the host. This value will be concatenated to `.spec.kubernetes.dnsZone` to calculate the FQDN for the host as `<name>.<dnsZone>`.

## .spec.kubernetes.loadBalancers.keepalived

### Properties

| Property                                                                 | Type      | Required |
|:-------------------------------------------------------------------------|:----------|:---------|
| [enabled](#speckubernetesloadbalancerskeepalivedenabled)                 | `boolean` | Required |
| [interface](#speckubernetesloadbalancerskeepalivedinterface)             | `string`  | Optional |
| [ip](#speckubernetesloadbalancerskeepalivedip)                           | `string`  | Optional |
| [passphrase](#speckubernetesloadbalancerskeepalivedpassphrase)           | `string`  | Optional |
| [virtualRouterId](#speckubernetesloadbalancerskeepalivedvirtualrouterid) | `string`  | Optional |

## .spec.kubernetes.loadBalancers.keepalived.enabled

### Description

Set to install keepalived with a floating virtual IP shared between the load balancer hosts for a deployment in High Availability.

## .spec.kubernetes.loadBalancers.keepalived.interface

### Description

Name of the network interface where to bind the Keepalived virtual IP.

## .spec.kubernetes.loadBalancers.keepalived.ip

### Description

The Virtual floating IP for Keepalived

## .spec.kubernetes.loadBalancers.keepalived.passphrase

### Description

Password for accessing vrrpd. Make it unique between Keepalived clusters.

### Constraints

**maximum length**: the maximum number of characters for this string is: `8`

## .spec.kubernetes.loadBalancers.keepalived.virtualRouterId

### Description

The virtual router ID of Keepalived, an arbitrary unique number from 1 to 255 used to differentiate multiple instances of vrrpd running on the same network interface and address family and multicast/unicast (and hence same socket).

## .spec.kubernetes.loadBalancers.stats

### Properties

| Property                                              | Type     | Required |
|:------------------------------------------------------|:---------|:---------|
| [password](#speckubernetesloadbalancersstatspassword) | `string` | Required |
| [username](#speckubernetesloadbalancersstatsusername) | `string` | Required |

### Description

Configuration for HAProxy stats page. Accessible at http://<haproxy host>:1936/stats

## .spec.kubernetes.loadBalancers.stats.password

### Description

The basic-auth password for HAProxy's stats page.

## .spec.kubernetes.loadBalancers.stats.username

### Description

The basic-auth username for HAProxy's stats page

## .spec.kubernetes.masters

### Properties

| Property                                                           | Type     | Required |
|:-------------------------------------------------------------------|:---------|:---------|
| [annotations](#speckubernetesmastersannotations)                   | `object` | Optional |
| [hosts](#speckubernetesmastershosts)                               | `array`  | Required |
| [kubeletConfiguration](#speckubernetesmasterskubeletconfiguration) | `object` | Optional |
| [labels](#speckubernetesmasterslabels)                             | `object` | Optional |

### Description

Configuration for the control plane hosts

## .spec.kubernetes.masters.annotations

### Description

Optional additional Kubernetes annotations that will be added to the control-plane nodes. Follows Kubernetes annotations format. **Existing annotations with the same key will be overwritten**.

## .spec.kubernetes.masters.hosts

### Properties

| Property                                | Type     | Required |
|:----------------------------------------|:---------|:---------|
| [ip](#speckubernetesmastershostsip)     | `string` | Required |
| [name](#speckubernetesmastershostsname) | `string` | Required |

## .spec.kubernetes.masters.hosts.ip

### Description

The IP address of the host

## .spec.kubernetes.masters.hosts.name

### Description

A name to identify the host. This value will be concatenated to `.spec.kubernetes.dnsZone` to calculate the FQDN for the host as `<name>.<dnsZone>`.

## .spec.kubernetes.masters.kubeletConfiguration

### Description

Advanced configuration for Kubelet. This open field allows users to specify any parameter supported by the `KubeletConfiguration` object. Examples of uses include controlling the maximum number of pods per core (`podsPerCore`), managing container logging (`containerLogMaxSize`), Topology Manager options (`topologyManagerPolicyOptions`). All values must follow the official Kubelet specification: https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/.

NOTE: Content will **not** be validated by furyctl. To customize the TLS cipher suites of the Kubelet, set only the `Spec.Kubernetes.Advanced.Encryption.tlsCipherSuites` field - do not configure them under this field.

## .spec.kubernetes.masters.labels

### Description

Optional additional Kubernetes labels that will be added to the control-plane nodes. Follows Kubernetes labels format.

Note: **Existing labels with the same key will be overwritten** and the label setting the `control-plane` role cannot be deleted.

## .spec.kubernetes.nodes

### Properties

| Property                                                         | Type     | Required |
|:-----------------------------------------------------------------|:---------|:---------|
| [annotations](#speckubernetesnodesannotations)                   | `object` | Optional |
| [hosts](#speckubernetesnodeshosts)                               | `array`  | Required |
| [kubeletConfiguration](#speckubernetesnodeskubeletconfiguration) | `object` | Optional |
| [labels](#speckubernetesnodeslabels)                             | `object` | Optional |
| [name](#speckubernetesnodesname)                                 | `string` | Required |
| [taints](#speckubernetesnodestaints)                             | `array`  | Optional |

### Description

Configuration for the node hosts

## .spec.kubernetes.nodes.annotations

### Description

Optional additional Kubernetes annotations that will be added to the nodes in this node group. Follows Kubernetes annotations format. **Existing annotations with the same key will be overwritten**.

## .spec.kubernetes.nodes.hosts

### Properties

| Property                              | Type     | Required |
|:--------------------------------------|:---------|:---------|
| [ip](#speckubernetesnodeshostsip)     | `string` | Required |
| [name](#speckubernetesnodeshostsname) | `string` | Required |

### Constraints

**minimum number of items**: the minimum number of items for this array is: `1`

## .spec.kubernetes.nodes.hosts.ip

### Description

The IP address of the host

## .spec.kubernetes.nodes.hosts.name

### Description

A name to identify the host. This value will be concatenated to `.spec.kubernetes.dnsZone` to calculate the FQDN for the host as `<name>.<dnsZone>`.

## .spec.kubernetes.nodes.kubeletConfiguration

### Description

Advanced configuration for Kubelet. This open field allows users to specify any parameter supported by the `KubeletConfiguration` object. Examples of uses include controlling the maximum number of pods per core (`podsPerCore`), managing container logging (`containerLogMaxSize`), Topology Manager options (`topologyManagerPolicyOptions`). All values must follow the official Kubelet specification: https://kubernetes.io/docs/reference/config-api/kubelet-config.v1beta1/.

NOTE: Content will **not** be validated by furyctl. To customize the TLS cipher suites of the Kubelet, set only the `Spec.Kubernetes.Advanced.Encryption.tlsCipherSuites` field - do not configure them under this field.

## .spec.kubernetes.nodes.labels

### Description

Optional additional Kubernetes labels that will be added to the nodes in this node group. Follows Kubernetes labels format.

Note: **Existing labels with the same key will be overwritten** and the label setting the node role to the node group name cannot be deleted.

## .spec.kubernetes.nodes.name

### Description

Name for the node group. It will be also used as the node role label. It should follow the [valid variable names guideline](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_variables.html#valid-variable-names) from Ansible.

## .spec.kubernetes.nodes.taints

### Properties

| Property                                   | Type     | Required |
|:-------------------------------------------|:---------|:---------|
| [effect](#speckubernetesnodestaintseffect) | `string` | Required |
| [key](#speckubernetesnodestaintskey)       | `string` | Required |
| [value](#speckubernetesnodestaintsvalue)   | `string` | Required |

## .spec.kubernetes.nodes.taints.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.kubernetes.nodes.taints.key

## .spec.kubernetes.nodes.taints.value

## .spec.kubernetes.pkiFolder

### Description

The path to the folder where the PKI files for Kubernetes and etcd are stored.

## .spec.kubernetes.podCidr

### Description

The subnet CIDR to use for the Pods network.

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}\/(3[0-2]|[1-2][0-9]|[0-9])$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.?\b\){4}\\/\(3[0-2]|[1-2][0-9]|[0-9]\)$)

## .spec.kubernetes.proxy

### Properties

| Property                               | Type     | Required |
|:---------------------------------------|:---------|:---------|
| [http](#speckubernetesproxyhttp)       | `string` | Optional |
| [https](#speckubernetesproxyhttps)     | `string` | Optional |
| [noProxy](#speckubernetesproxynoproxy) | `string` | Optional |

## .spec.kubernetes.proxy.http

### Description

The HTTP proxy URL. Example: http://test.example.dev:3128

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^(http|https)\:\/\/.+$
```

[try pattern](https://regexr.com/?expression=^\(http|https\)\:\\/\\/.%2B$)

## .spec.kubernetes.proxy.https

### Description

The HTTPS proxy URL. Example: https://test.example.dev:3128

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^(http|https)\:\/\/.+$
```

[try pattern](https://regexr.com/?expression=^\(http|https\)\:\\/\\/.%2B$)

## .spec.kubernetes.proxy.noProxy

### Description

Comma-separated list of hosts that should not use the HTTP(S) proxy. Example:
localhost,127.0.0.1,172.16.0.0/17,172.16.128.0/17,10.0.0.0/8,.example.dev

## .spec.kubernetes.ssh

### Properties

| Property                               | Type     | Required |
|:---------------------------------------|:---------|:---------|
| [keyPath](#speckubernetessshkeypath)   | `string` | Required |
| [username](#speckubernetessshusername) | `string` | Required |

### Description

SSH credentials to access the hosts

## .spec.kubernetes.ssh.keyPath

### Description

The path to the private key to use to connect to the hosts

## .spec.kubernetes.ssh.username

### Description

The username to use to connect to the hosts

## .spec.kubernetes.svcCidr

### Description

The subnet CIDR to use for the Services network.

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.?\b){4}\/(3[0-2]|[1-2][0-9]|[0-9])$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.?\b\){4}\\/\(3[0-2]|[1-2][0-9]|[0-9]\)$)

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

The name of the kustomize plugin

