# SD Immutable Kind Schema

This document explains the full schema for the `kind: Immutable` for the `furyctl.yaml` file used by `furyctl`. This configuration file will be used to provision and deploy bare metal nodes with iPXE boot, storage partitioning, network configuration, and the SIGHUP Distribution modules for immutable Kubernetes infrastructure.

An example configuration file can be created by running the following command:

```bash
furyctl create config --kind Immutable --version v1.34.0 --name test-cluster
```

> [!NOTE]
> Replace the version with your desired version of the SIGHUP Distribution.

## Properties

| Property                  | Type     | Required |
|:--------------------------|:---------|:---------|
| [apiVersion](#apiversion) | `string` | Required |
| [flags](#flags)           | `object` | Optional |
| [kind](#kind)             | `string` | Required |
| [metadata](#metadata)     | `object` | Required |
| [spec](#spec)             | `object` | Required |

### Description

A SIGHUP Distribution Kubernetes Cluster deployed on bare metal infrastructure with iPXE boot provisioning and immutable OS configuration.

## .apiVersion

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^kfd\.sighup\.io/v\d+((alpha|beta)\d+)?$
```

[try pattern](https://regexr.com/?expression=^kfd\.sighup\.io\/v\d%2B\(\(alpha|beta\)\d%2B\)?$)

## .flags

### Description

Persistent furyctl command flags, see the documentation for more details: https://docs.sighup.io/furyctl/flags-configuration

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
| [toolsConfiguration](#spectoolsconfiguration)   | `object` | Optional |

## .spec.distribution

### Properties

| Property                                            | Type     | Required |
|:----------------------------------------------------|:---------|:---------|
| [common](#specdistributioncommon)                   | `object` | Optional |
| [customPatches](#specdistributioncustompatches)     | `object` | Optional |
| [customResources](#specdistributioncustomresources) | `object` | Optional |
| [modules](#specdistributionmodules)                 | `object` | Required |

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

The node selector to use to place the pods for all the SD modules. Follows Kubernetes selector format. Example: `node.kubernetes.io/role: infra`.

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

An array with the tolerations that will be added to the pods for all the SD modules. Follows Kubernetes tolerations format. Example:

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

## .spec.distribution.customResources

### Description

Add custom resources to the distribution phase. Each entry should point to a resource file, a kustomize base, or a remote resource (e.g. a git repository or URL). `customResources` should be used when you _need_ the resources to be applyed in the distribution phase together with the rest of the modules; prefer using Plugins instead when possible.

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
| [ingressForecastle](#specdistributionmodulesauthpomeriumdefaultroutespolicyingressforecastle)                     | `array` | Optional |
| [loggingMinioConsole](#specdistributionmodulesauthpomeriumdefaultroutespolicyloggingminioconsole)                 | `array` | Optional |
| [loggingOpensearchDashboards](#specdistributionmodulesauthpomeriumdefaultroutespolicyloggingopensearchdashboards) | `array` | Optional |
| [monitoringAlertmanager](#specdistributionmodulesauthpomeriumdefaultroutespolicymonitoringalertmanager)           | `array` | Optional |
| [monitoringGrafana](#specdistributionmodulesauthpomeriumdefaultroutespolicymonitoringgrafana)                     | `array` | Optional |
| [monitoringMinioConsole](#specdistributionmodulesauthpomeriumdefaultroutespolicymonitoringminioconsole)           | `array` | Optional |
| [monitoringPrometheus](#specdistributionmodulesauthpomeriumdefaultroutespolicymonitoringprometheus)               | `array` | Optional |
| [tracingMinioConsole](#specdistributionmodulesauthpomeriumdefaultroutespolicytracingminioconsole)                 | `array` | Optional |
| [whisker](#specdistributionmodulesauthpomeriumdefaultroutespolicywhisker)                                         | `array` | Optional |

### Description

override default routes for SD components

## .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.gatekeeperPolicyManager

## .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.hubbleUi

## .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.ingressForecastle

## .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.loggingMinioConsole

## .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.loggingOpensearchDashboards

## .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.monitoringAlertmanager

## .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.monitoringGrafana

## .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.monitoringMinioConsole

## .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.monitoringPrometheus

## .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.tracingMinioConsole

## .spec.distribution.modules.auth.pomerium.defaultRoutesPolicy.whisker

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
openssl ecparam -genkey -name prime256v1 -noout -out ec_private.pem
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
| [gcs](#specdistributionmodulesdrvelerogcs)                               | `object` | Optional |
| [nodeAgent](#specdistributionmodulesdrveleronodeagent)                   | `object` | Optional |
| [overrides](#specdistributionmodulesdrvelerooverrides)                   | `object` | Optional |
| [schedules](#specdistributionmodulesdrveleroschedules)                   | `object` | Optional |
| [snapshotController](#specdistributionmodulesdrvelerosnapshotcontroller) | `object` | Optional |

### Description

Configuration for the Velero package.

## .spec.distribution.modules.dr.velero.backend

### Description

The storage backend type for Velero. `minio` will use an in-cluster MinIO deployment for object storage, `externalEndpoint` can be used to point to an external S3-compatible object storage instead of deploying an in-cluster MinIO, `gcs` can be used to point to an external GCS object storage instead of deploying an in-cluster MinIO.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"minio"`           |
|`"externalEndpoint"`|
|`"gcs"`             |

## .spec.distribution.modules.dr.velero.externalEndpoint

### Properties

| Property                                                                           | Type      | Required |
|:-----------------------------------------------------------------------------------|:----------|:---------|
| [accessKeyId](#specdistributionmodulesdrveleroexternalendpointaccesskeyid)         | `string`  | Optional |
| [accessMode](#specdistributionmodulesdrveleroexternalendpointaccessmode)           | `string`  | Optional |
| [bucketName](#specdistributionmodulesdrveleroexternalendpointbucketname)           | `string`  | Optional |
| [endpoint](#specdistributionmodulesdrveleroexternalendpointendpoint)               | `string`  | Optional |
| [insecure](#specdistributionmodulesdrveleroexternalendpointinsecure)               | `boolean` | Optional |
| [prefixName](#specdistributionmodulesdrveleroexternalendpointprefixname)           | `string`  | Optional |
| [secretAccessKey](#specdistributionmodulesdrveleroexternalendpointsecretaccesskey) | `string`  | Optional |

### Description

Configuration for Velero's external storage backend.

## .spec.distribution.modules.dr.velero.externalEndpoint.accessKeyId

### Description

The access key ID (username) for the external S3-compatible bucket.

## .spec.distribution.modules.dr.velero.externalEndpoint.accessMode

### Description

How Velero can access the backup storage location.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value       |
|:------------|
|`"ReadWrite"`|
|`"ReadOnly"` |

## .spec.distribution.modules.dr.velero.externalEndpoint.bucketName

### Description

The bucket name of the external object storage.

## .spec.distribution.modules.dr.velero.externalEndpoint.endpoint

### Description

External S3-compatible endpoint for Velero's storage.

## .spec.distribution.modules.dr.velero.externalEndpoint.insecure

### Description

If true, will use HTTP as protocol instead of HTTPS.

## .spec.distribution.modules.dr.velero.externalEndpoint.prefixName

### Description

The prefix name to use inside the bucket.

## .spec.distribution.modules.dr.velero.externalEndpoint.secretAccessKey

### Description

The secret access key (password) for the external S3-compatible bucket.

## .spec.distribution.modules.dr.velero.gcs

### Properties

| Property                                                                        | Type     | Required |
|:--------------------------------------------------------------------------------|:---------|:---------|
| [accessMode](#specdistributionmodulesdrvelerogcsaccessmode)                     | `string` | Optional |
| [bucketName](#specdistributionmodulesdrvelerogcsbucketname)                     | `string` | Optional |
| [clientEmail](#specdistributionmodulesdrvelerogcsclientemail)                   | `string` | Optional |
| [prefixName](#specdistributionmodulesdrvelerogcsprefixname)                     | `string` | Optional |
| [serviceAccountString](#specdistributionmodulesdrvelerogcsserviceaccountstring) | `string` | Optional |

### Description

Configuration for Velero's gcs storage backend.

## .spec.distribution.modules.dr.velero.gcs.accessMode

### Description

How Velero can access the backup storage location.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value       |
|:------------|
|`"ReadWrite"`|
|`"ReadOnly"` |

## .spec.distribution.modules.dr.velero.gcs.bucketName

### Description

The bucket name of the gcs object storage.

## .spec.distribution.modules.dr.velero.gcs.clientEmail

### Description

Full gcs client email.

## .spec.distribution.modules.dr.velero.gcs.prefixName

### Description

The prefix name to use inside the gcs bucket.

## .spec.distribution.modules.dr.velero.gcs.serviceAccountString

### Description

Service gcs account JSON string.

## .spec.distribution.modules.dr.velero.nodeAgent

### Properties

| Property                                                                          | Type      | Required |
|:----------------------------------------------------------------------------------|:----------|:---------|
| [prepareQueueLength](#specdistributionmodulesdrveleronodeagentpreparequeuelength) | `integer` | Optional |

### Description

Configuration for Velero's node-agent DaemonSet.

## .spec.distribution.modules.dr.velero.nodeAgent.prepareQueueLength

### Description

Defines the maximum number of DataUpload/DataDownload/PodVolumeBackup/PodVolumeRestore CRs under preparation statuses but not yet processed by any node. This constrains the number of intermediate objects (PVCs, VolumeSnapshots, etc.) to prevent unnecessary resource usage when cluster parallelism is limited.

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

| Property                                                                                          | Type     | Required |
|:--------------------------------------------------------------------------------------------------|:---------|:---------|
| [baseDomain](#specdistributionmodulesingressbasedomain)                                           | `string` | Required |
| [byoic](#specdistributionmodulesingressbyoic)                                                     | `object` | Optional |
| [certManager](#specdistributionmodulesingresscertmanager)                                         | `object` | Optional |
| [forecastle](#specdistributionmodulesingressforecastle)                                           | `object` | Optional |
| [haproxy](#specdistributionmodulesingresshaproxy)                                                 | `object` | Optional |
| [infrastructureIngressController](#specdistributionmodulesingressinfrastructureingresscontroller) | `string` | Optional |
| [nginx](#specdistributionmodulesingressnginx)                                                     | `object` | Optional |
| [overrides](#specdistributionmodulesingressoverrides)                                             | `object` | Optional |

## .spec.distribution.modules.ingress.baseDomain

### Description

The base domain used for all the SD's infrastructural ingresses. If using the nginx `dual` type, this value should be the same as the domain associated with the `internal` ingress class.

## .spec.distribution.modules.ingress.byoic

### Properties

| Property                                                                   | Type      | Required |
|:---------------------------------------------------------------------------|:----------|:---------|
| [commonAnnotations](#specdistributionmodulesingressbyoiccommonannotations) | `object`  | Optional |
| [enabled](#specdistributionmodulesingressbyoicenabled)                     | `boolean` | Required |
| [ingressClass](#specdistributionmodulesingressbyoicingressclass)           | `string`  | Optional |

### Description

Configuration for Bring Your Own Ingress Controller mode. The ingressClass is used for infrastructure ingresses when both controllers are disabled.

## .spec.distribution.modules.ingress.byoic.commonAnnotations

### Description

Annotations to apply to all infrastructure ingresses when using this BYOIC ingress class. Useful for controller-specific configuration (TLS, auth middlewares, etc.).

## .spec.distribution.modules.ingress.byoic.enabled

### Description

Enable BYOIC mode.

## .spec.distribution.modules.ingress.byoic.ingressClass

### Description

The IngressClass to use for infrastructure ingresses (Prometheus, Grafana, etc.) when both nginx and haproxy are disabled.

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

## .spec.distribution.modules.ingress.haproxy

### Properties

| Property                                                     | Type     | Required |
|:-------------------------------------------------------------|:---------|:---------|
| [overrides](#specdistributionmodulesingresshaproxyoverrides) | `object` | Optional |
| [tls](#specdistributionmodulesingresshaproxytls)             | `object` | Optional |
| [type](#specdistributionmodulesingresshaproxytype)           | `string` | Required |

### Description

Configuration for HAProxy Kubernetes Ingress Controller.

## .spec.distribution.modules.ingress.haproxy.overrides

### Properties

| Property                                                                    | Type     | Required |
|:----------------------------------------------------------------------------|:---------|:---------|
| [nodeSelector](#specdistributionmodulesingresshaproxyoverridesnodeselector) | `object` | Optional |
| [tolerations](#specdistributionmodulesingresshaproxyoverridestolerations)   | `array`  | Optional |

## .spec.distribution.modules.ingress.haproxy.overrides.nodeSelector

### Description

Set to override the node selector used to place the pods of the package.

## .spec.distribution.modules.ingress.haproxy.overrides.tolerations

### Properties

| Property                                                                       | Type     | Required |
|:-------------------------------------------------------------------------------|:---------|:---------|
| [effect](#specdistributionmodulesingresshaproxyoverridestolerationseffect)     | `string` | Required |
| [key](#specdistributionmodulesingresshaproxyoverridestolerationskey)           | `string` | Required |
| [operator](#specdistributionmodulesingresshaproxyoverridestolerationsoperator) | `string` | Optional |
| [value](#specdistributionmodulesingresshaproxyoverridestolerationsvalue)       | `string` | Optional |

### Description

Set to override the tolerations that will be added to the pods of the package.

## .spec.distribution.modules.ingress.haproxy.overrides.tolerations.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.distribution.modules.ingress.haproxy.overrides.tolerations.key

### Description

The key of the toleration

## .spec.distribution.modules.ingress.haproxy.overrides.tolerations.operator

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"Exists"`|
|`"Equal"` |

## .spec.distribution.modules.ingress.haproxy.overrides.tolerations.value

### Description

The value of the toleration

## .spec.distribution.modules.ingress.haproxy.tls

### Properties

| Property                                                      | Type     | Required |
|:--------------------------------------------------------------|:---------|:---------|
| [provider](#specdistributionmodulesingresshaproxytlsprovider) | `string` | Required |
| [secret](#specdistributionmodulesingresshaproxytlssecret)     | `object` | Optional |

### Description

TLS configuration for the HAProxy Kubernetes Ingress Controller.

## .spec.distribution.modules.ingress.haproxy.tls.provider

### Description

The provider of the TLS certificates for the ingresses, one of: `none`, `certManager`, or `secret`.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value         |
|:--------------|
|`"certManager"`|
|`"secret"`     |
|`"none"`       |

## .spec.distribution.modules.ingress.haproxy.tls.secret

### Properties

| Property                                                    | Type     | Required |
|:------------------------------------------------------------|:---------|:---------|
| [ca](#specdistributionmodulesingresshaproxytlssecretca)     | `string` | Required |
| [cert](#specdistributionmodulesingresshaproxytlssecretcert) | `string` | Required |
| [key](#specdistributionmodulesingresshaproxytlssecretkey)   | `string` | Required |

### Description

Kubernetes TLS secret for the HAProxy ingresses TLS certificate.

## .spec.distribution.modules.ingress.haproxy.tls.secret.ca

### Description

The Certificate Authority certificate file's content. You can use the `"{file://<path>}"` notation to get the content from a file.

## .spec.distribution.modules.ingress.haproxy.tls.secret.cert

### Description

The certificate file's content. You can use the `"{file://<path>}"` notation to get the content from a file.

## .spec.distribution.modules.ingress.haproxy.tls.secret.key

### Description

The signing key file's content. You can use the `"{file://<path>}"` notation to get the content from a file.

## .spec.distribution.modules.ingress.haproxy.type

### Description

The type of the HAProxy Kubernetes Ingress Controller, options are:
- `none`: HAProxy ingress controller will not be installed.
- `single`: a single HAProxy ingress controller with ingress class `haproxy` will be installed.
- `dual`: two independent HAProxy ingress controllers will be installed, one for the `haproxy-internal` ingress class and one for the `haproxy-external` ingress class.

Default is `none`.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value    |
|:---------|
|`"none"`  |
|`"single"`|
|`"dual"`  |

## .spec.distribution.modules.ingress.infrastructureIngressController

### Description

Overrides the default ingress controller for SD infrastructure ingresses. Set to `nginx` or `haproxy` to select the controller family; the dual/single class mapping (e.g., `haproxy-internal`/`haproxy-external`) is applied automatically based on the controller's type setting. Useful during migrations to keep infrastructure ingresses on one controller while testing another. Do not use this field when both `nginx.type` and `haproxy.type` are `none`: in that case rely on `byoic.ingressClass` to define the ingress class for SD ingresses.

## .spec.distribution.modules.ingress.nginx

### Properties

| Property                                                   | Type     | Required |
|:-----------------------------------------------------------|:---------|:---------|
| [overrides](#specdistributionmodulesingressnginxoverrides) | `object` | Optional |
| [tls](#specdistributionmodulesingressnginxtls)             | `object` | Optional |
| [type](#specdistributionmodulesingressnginxtype)           | `string` | Required |

### Description

(DEPRECATED) Configurations for the Ingress NGINX Controller package.

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

### Description

TLS configuration for the Ingress NGINX Controller.

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
- `dual`: two independent ingress controllers will be installed, one for the `internal` ingress class intended for private ingresses and one for the `external` ingress class intended for public ingresses. SD's infrastructural ingresses wil use the `internal` ingress class when using the dual type.

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

## .spec.distribution.modules.logging

### Properties

| Property                                                      | Type     | Required |
|:--------------------------------------------------------------|:---------|:---------|
| [customOutputs](#specdistributionmodulesloggingcustomoutputs) | `object` | Optional |
| [loki](#specdistributionmodulesloggingloki)                   | `object` | Optional |
| [minio](#specdistributionmodulesloggingminio)                 | `object` | Optional |
| [opensearch](#specdistributionmodulesloggingopensearch)       | `object` | Optional |
| [operator](#specdistributionmodulesloggingoperator)           | `object` | Optional |
| [overrides](#specdistributionmodulesloggingoverrides)         | `object` | Optional |
| [type](#specdistributionmodulesloggingtype)                   | `string` | Required |

### Description

Configuration for the Logging module.

## .spec.distribution.modules.logging.customOutputs

### Properties

| Property                                                                     | Type     | Required |
|:-----------------------------------------------------------------------------|:---------|:---------|
| [audit](#specdistributionmodulesloggingcustomoutputsaudit)                   | `string` | Required |
| [errors](#specdistributionmodulesloggingcustomoutputserrors)                 | `string` | Required |
| [events](#specdistributionmodulesloggingcustomoutputsevents)                 | `string` | Required |
| [infra](#specdistributionmodulesloggingcustomoutputsinfra)                   | `string` | Required |
| [ingressHaproxy](#specdistributionmodulesloggingcustomoutputsingresshaproxy) | `string` | Required |
| [ingressNginx](#specdistributionmodulesloggingcustomoutputsingressnginx)     | `string` | Required |
| [kubernetes](#specdistributionmodulesloggingcustomoutputskubernetes)         | `string` | Required |
| [systemdCommon](#specdistributionmodulesloggingcustomoutputssystemdcommon)   | `string` | Required |
| [systemdEtcd](#specdistributionmodulesloggingcustomoutputssystemdetcd)       | `string` | Required |

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

## .spec.distribution.modules.logging.customOutputs.ingressHaproxy

### Description

This value defines where the output from the `ingressHaproxy` Flow will be sent. This will be the `spec` section of the `Output` object. It must be a string (and not a YAML object) following the OutputSpec definition. Use the `nullout` output to discard the flow: `nullout: {}`

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

The CPU limit for the Pod, in cores or millicores. Examples: 1000m, 2, 1.5

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(m|)$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(m|\)$)

## .spec.distribution.modules.logging.loki.resources.limits.memory

### Description

Kubernetes resource quantity format. Examples: 50Gi, 100Mi, 1Ti

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk])$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk]\)$)

## .spec.distribution.modules.logging.loki.resources.requests

### Properties

| Property                                                             | Type     | Required |
|:---------------------------------------------------------------------|:---------|:---------|
| [cpu](#specdistributionmoduleslogginglokiresourcesrequestscpu)       | `string` | Optional |
| [memory](#specdistributionmoduleslogginglokiresourcesrequestsmemory) | `string` | Optional |

## .spec.distribution.modules.logging.loki.resources.requests.cpu

### Description

The CPU request for the Pod, in cores or millicores. Examples: 500m, 1, 0.5

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(m|)$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(m|\)$)

## .spec.distribution.modules.logging.loki.resources.requests.memory

### Description

Kubernetes resource quantity format. Examples: 50Gi, 100Mi, 1Ti

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk])$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk]\)$)

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

The CPU limit for the Pod, in cores or millicores. Examples: 1000m, 2, 1.5

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(m|)$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(m|\)$)

## .spec.distribution.modules.logging.opensearch.resources.limits.memory

### Description

Kubernetes resource quantity format. Examples: 50Gi, 100Mi, 1Ti

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk])$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk]\)$)

## .spec.distribution.modules.logging.opensearch.resources.requests

### Properties

| Property                                                                   | Type     | Required |
|:---------------------------------------------------------------------------|:---------|:---------|
| [cpu](#specdistributionmodulesloggingopensearchresourcesrequestscpu)       | `string` | Optional |
| [memory](#specdistributionmodulesloggingopensearchresourcesrequestsmemory) | `string` | Optional |

## .spec.distribution.modules.logging.opensearch.resources.requests.cpu

### Description

The CPU request for the Pod, in cores or millicores. Examples: 500m, 1, 0.5

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(m|)$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(m|\)$)

## .spec.distribution.modules.logging.opensearch.resources.requests.memory

### Description

Kubernetes resource quantity format. Examples: 50Gi, 100Mi, 1Ti

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk])$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk]\)$)

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
| [fluentbit](#specdistributionmodulesloggingoperatorfluentbit) | `object` | Optional |
| [fluentd](#specdistributionmodulesloggingoperatorfluentd)     | `object` | Optional |
| [overrides](#specdistributionmodulesloggingoperatoroverrides) | `object` | Optional |

### Description

Configuration for the Logging Operator.

## .spec.distribution.modules.logging.operator.fluentbit

### Properties

| Property                                                               | Type     | Required |
|:-----------------------------------------------------------------------|:---------|:---------|
| [resources](#specdistributionmodulesloggingoperatorfluentbitresources) | `object` | Optional |

### Description

Configuration for Fluent Bit that reads the logs from the workload and forwards them to Fluentd.

## .spec.distribution.modules.logging.operator.fluentbit.resources

### Properties

| Property                                                                      | Type     | Required |
|:------------------------------------------------------------------------------|:---------|:---------|
| [limits](#specdistributionmodulesloggingoperatorfluentbitresourceslimits)     | `object` | Optional |
| [requests](#specdistributionmodulesloggingoperatorfluentbitresourcesrequests) | `object` | Optional |

## .spec.distribution.modules.logging.operator.fluentbit.resources.limits

### Properties

| Property                                                                        | Type     | Required |
|:--------------------------------------------------------------------------------|:---------|:---------|
| [cpu](#specdistributionmodulesloggingoperatorfluentbitresourceslimitscpu)       | `string` | Optional |
| [memory](#specdistributionmodulesloggingoperatorfluentbitresourceslimitsmemory) | `string` | Optional |

## .spec.distribution.modules.logging.operator.fluentbit.resources.limits.cpu

### Description

The CPU limit for the Pod, in cores or millicores. Examples: 1000m, 2, 1.5

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(m|)$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(m|\)$)

## .spec.distribution.modules.logging.operator.fluentbit.resources.limits.memory

### Description

Kubernetes resource quantity format. Examples: 50Gi, 100Mi, 1Ti

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk])$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk]\)$)

## .spec.distribution.modules.logging.operator.fluentbit.resources.requests

### Properties

| Property                                                                          | Type     | Required |
|:----------------------------------------------------------------------------------|:---------|:---------|
| [cpu](#specdistributionmodulesloggingoperatorfluentbitresourcesrequestscpu)       | `string` | Optional |
| [memory](#specdistributionmodulesloggingoperatorfluentbitresourcesrequestsmemory) | `string` | Optional |

## .spec.distribution.modules.logging.operator.fluentbit.resources.requests.cpu

### Description

The CPU request for the Pod, in cores or millicores. Examples: 500m, 1, 0.5

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(m|)$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(m|\)$)

## .spec.distribution.modules.logging.operator.fluentbit.resources.requests.memory

### Description

Kubernetes resource quantity format. Examples: 50Gi, 100Mi, 1Ti

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk])$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk]\)$)

## .spec.distribution.modules.logging.operator.fluentd

### Properties

| Property                                                             | Type      | Required |
|:---------------------------------------------------------------------|:----------|:---------|
| [replicas](#specdistributionmodulesloggingoperatorfluentdreplicas)   | `integer` | Optional |
| [resources](#specdistributionmodulesloggingoperatorfluentdresources) | `object`  | Optional |

### Description

Configuration for Fluentd that collects the logs and forwards them to the outputs.

## .spec.distribution.modules.logging.operator.fluentd.replicas

### Description

The number of Fluentd replicas to run. Default is `2`.

## .spec.distribution.modules.logging.operator.fluentd.resources

### Properties

| Property                                                                    | Type     | Required |
|:----------------------------------------------------------------------------|:---------|:---------|
| [limits](#specdistributionmodulesloggingoperatorfluentdresourceslimits)     | `object` | Optional |
| [requests](#specdistributionmodulesloggingoperatorfluentdresourcesrequests) | `object` | Optional |

## .spec.distribution.modules.logging.operator.fluentd.resources.limits

### Properties

| Property                                                                      | Type     | Required |
|:------------------------------------------------------------------------------|:---------|:---------|
| [cpu](#specdistributionmodulesloggingoperatorfluentdresourceslimitscpu)       | `string` | Optional |
| [memory](#specdistributionmodulesloggingoperatorfluentdresourceslimitsmemory) | `string` | Optional |

## .spec.distribution.modules.logging.operator.fluentd.resources.limits.cpu

### Description

The CPU limit for the Pod, in cores or millicores. Examples: 1000m, 2, 1.5

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(m|)$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(m|\)$)

## .spec.distribution.modules.logging.operator.fluentd.resources.limits.memory

### Description

Kubernetes resource quantity format. Examples: 50Gi, 100Mi, 1Ti

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk])$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk]\)$)

## .spec.distribution.modules.logging.operator.fluentd.resources.requests

### Properties

| Property                                                                        | Type     | Required |
|:--------------------------------------------------------------------------------|:---------|:---------|
| [cpu](#specdistributionmodulesloggingoperatorfluentdresourcesrequestscpu)       | `string` | Optional |
| [memory](#specdistributionmodulesloggingoperatorfluentdresourcesrequestsmemory) | `string` | Optional |

## .spec.distribution.modules.logging.operator.fluentd.resources.requests.cpu

### Description

The CPU request for the Pod, in cores or millicores. Examples: 500m, 1, 0.5

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(m|)$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(m|\)$)

## .spec.distribution.modules.logging.operator.fluentd.resources.requests.memory

### Description

Kubernetes resource quantity format. Examples: 50Gi, 100Mi, 1Ti

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk])$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk]\)$)

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

The CPU limit for the Pod, in cores or millicores. Examples: 1000m, 2, 1.5

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(m|)$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(m|\)$)

## .spec.distribution.modules.monitoring.prometheus.resources.limits.memory

### Description

Kubernetes resource quantity format. Examples: 50Gi, 100Mi, 1Ti

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk])$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk]\)$)

## .spec.distribution.modules.monitoring.prometheus.resources.requests

### Properties

| Property                                                                      | Type     | Required |
|:------------------------------------------------------------------------------|:---------|:---------|
| [cpu](#specdistributionmodulesmonitoringprometheusresourcesrequestscpu)       | `string` | Optional |
| [memory](#specdistributionmodulesmonitoringprometheusresourcesrequestsmemory) | `string` | Optional |

## .spec.distribution.modules.monitoring.prometheus.resources.requests.cpu

### Description

The CPU request for the Pod, in cores or millicores. Examples: 500m, 1, 0.5

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(m|)$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(m|\)$)

## .spec.distribution.modules.monitoring.prometheus.resources.requests.memory

### Description

Kubernetes resource quantity format. Examples: 50Gi, 100Mi, 1Ti

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk])$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk]\)$)

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

The CPU limit for the Pod, in cores or millicores. Examples: 1000m, 2, 1.5

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(m|)$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(m|\)$)

## .spec.distribution.modules.monitoring.prometheusAgent.resources.limits.memory

### Description

Kubernetes resource quantity format. Examples: 50Gi, 100Mi, 1Ti

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk])$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(Ei?|Pi?|Ti?|Gi?|Mi?|Ki?|[EPTGMk]\)$)

## .spec.distribution.modules.monitoring.prometheusAgent.resources.requests

### Properties

| Property                                                                           | Type     | Required |
|:-----------------------------------------------------------------------------------|:---------|:---------|
| [cpu](#specdistributionmodulesmonitoringprometheusagentresourcesrequestscpu)       | `string` | Optional |
| [memory](#specdistributionmodulesmonitoringprometheusagentresourcesrequestsmemory) | `string` | Optional |

## .spec.distribution.modules.monitoring.prometheusAgent.resources.requests.cpu

### Description

The CPU request for the Pod, in cores or millicores. Examples: 500m, 1, 0.5

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^[0-9]+(\.[0-9]+)?(m|)$
```

[try pattern](https://regexr.com/?expression=^[0-9]%2B\(\.[0-9]%2B\)?\(m|\)$)

## .spec.distribution.modules.monitoring.prometheusAgent.resources.requests.memory

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
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.){3}(25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\/(3[0-2]|[1-2][0-9]|[0-9])$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.\){3}\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\\/\(3[0-2]|[1-2][0-9]|[0-9]\)$)

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

BlockSize specifies the CIDR prefix length to use when allocating per-node IP blocks from the main IP pool CIDR. WARNING: The value for this field cannot be changed once set. Default is 26.

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

Allows specifing a CIDR for the Pods network different from `.spec.kubernetes.podCidr`. If not set the default is to use `.spec.kubernetes.podCidr`. WARNING: The value for this field cannot be changed once set.

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.){3}(25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\/(3[0-2]|[1-2][0-9]|[0-9])$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.\){3}\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\\/\(3[0-2]|[1-2][0-9]|[0-9]\)$)

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

Defines which SD version will be installed and, in consequence, the Kubernetes version used to create the cluster. It supports git tags and branches. Example: `v1.32.1`.

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.infrastructure

### Properties

| Property                                                | Type     | Required |
|:--------------------------------------------------------|:---------|:---------|
| [ipxeServer](#specinfrastructureipxeserver)             | `object` | Optional |
| [kernelParameters](#specinfrastructurekernelparameters) | `array`  | Optional |
| [loadBalancers](#specinfrastructureloadbalancers)       | `object` | Optional |
| [nodes](#specinfrastructurenodes)                       | `array`  | Required |
| [proxy](#specinfrastructureproxy)                       | `object` | Optional |
| [ssh](#specinfrastructuressh)                           | `object` | Required |

### Description

Defines the bare metal infrastructure configuration, including nodes, network boot, storage, and networking.

## .spec.infrastructure.ipxeServer

### Properties

| Property                                                                | Type      | Required |
|:------------------------------------------------------------------------|:----------|:---------|
| [bindAddress](#specinfrastructureipxeserverbindaddress)                 | `string`  | Optional |
| [bindPort](#specinfrastructureipxeserverbindport)                       | `integer` | Optional |
| [postInstallCommands](#specinfrastructureipxeserverpostinstallcommands) | `array`   | Optional |
| [preInstallCommands](#specinfrastructureipxeserverpreinstallcommands)   | `array`   | Optional |
| [url](#specinfrastructureipxeserverurl)                                 | `string`  | Required |

### Description

iPXE server configuration for network boot provisioning. Ref: https://www.flatcar.org/docs/latest/setup/customization/

## .spec.infrastructure.ipxeServer.bindAddress

### Description

The address where the iPXE server will listen for incoming requests. Default is the address from the URL

## .spec.infrastructure.ipxeServer.bindPort

### Description

The port where the iPXE server will listen for incoming requests. Default is the port from the URL or 80 if not specified.

## .spec.infrastructure.ipxeServer.postInstallCommands

### Description

List of commands to execute after installing Flatcar to disk and before rebooting the node

## .spec.infrastructure.ipxeServer.preInstallCommands

### Description

List of commands to execute before installing Flatcar to disk

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

## .spec.infrastructure.loadBalancers

### Properties

| Property                                                 | Type     | Required |
|:---------------------------------------------------------|:---------|:---------|
| [containerd](#specinfrastructureloadbalancerscontainerd) | `object` | Optional |
| [haproxy](#specinfrastructureloadbalancershaproxy)       | `object` | Optional |
| [keepalived](#specinfrastructureloadbalancerskeepalived) | `object` | Optional |
| [members](#specinfrastructureloadbalancersmembers)       | `array`  | Optional |

### Description

Load balancer configuration. Uses HAProxy for load balancing and keepalived for VIP failover between LB nodes. Having members defined will enable the load balancers.

## .spec.infrastructure.loadBalancers.containerd

### Properties

| Property                                                                                                           | Type      | Required |
|:-------------------------------------------------------------------------------------------------------------------|:----------|:---------|
| [debugLevel](#specinfrastructureloadbalancerscontainerddebuglevel)                                                 | `string`  | Optional |
| [deviceOwnershipFromSecurityContext](#specinfrastructureloadbalancerscontainerddeviceownershipfromsecuritycontext) | `boolean` | Optional |
| [grpcMaxRecvMessageSize](#specinfrastructureloadbalancerscontainerdgrpcmaxrecvmessagesize)                         | `integer` | Optional |
| [grpcMaxSendMessageSize](#specinfrastructureloadbalancerscontainerdgrpcmaxsendmessagesize)                         | `integer` | Optional |
| [maxContainerLogLineSize](#specinfrastructureloadbalancerscontainerdmaxcontainerloglinesize)                       | `integer` | Optional |
| [metricsAddress](#specinfrastructureloadbalancerscontainerdmetricsaddress)                                         | `string`  | Optional |
| [metricsGrpcHistogram](#specinfrastructureloadbalancerscontainerdmetricsgrpchistogram)                             | `boolean` | Optional |
| [oomScore](#specinfrastructureloadbalancerscontainerdoomscore)                                                     | `integer` | Optional |
| [registryConfigs](#specinfrastructureloadbalancerscontainerdregistryconfigs)                                       | `array`   | Optional |
| [selfmanagedRepositories](#specinfrastructureloadbalancerscontainerdselfmanagedrepositories)                       | `boolean` | Optional |
| [stateDir](#specinfrastructureloadbalancerscontainerdstatedir)                                                     | `string`  | Optional |
| [storageDir](#specinfrastructureloadbalancerscontainerdstoragedir)                                                 | `string`  | Optional |
| [systemdDir](#specinfrastructureloadbalancerscontainerdsystemddir)                                                 | `string`  | Optional |

### Description

Advanced configuration for containerd

## .spec.infrastructure.loadBalancers.containerd.debugLevel

### Description

The Containerd debug level used in the config.toml file.

## .spec.infrastructure.loadBalancers.containerd.deviceOwnershipFromSecurityContext

### Description

Set to true to apply device ownership from the container runtime's security context instead of the host's defaults, used in the config.toml file.

## .spec.infrastructure.loadBalancers.containerd.grpcMaxRecvMessageSize

### Description

The Containerd gRPC maximum receive message size in bytes used in the config.toml file.

## .spec.infrastructure.loadBalancers.containerd.grpcMaxSendMessageSize

### Description

The Containerd gRPC maximum send message size in bytes used in the config.toml file.

## .spec.infrastructure.loadBalancers.containerd.maxContainerLogLineSize

### Description

The maximum container log line size in bytes used in the config.toml file.

## .spec.infrastructure.loadBalancers.containerd.metricsAddress

### Description

The Containerd metrics address used in the config.toml file.

## .spec.infrastructure.loadBalancers.containerd.metricsGrpcHistogram

### Description

Enable Containerd metrics gRPC histogram in the config.toml file.

## .spec.infrastructure.loadBalancers.containerd.oomScore

### Description

The Containerd OOM score adjustment used in the config.toml file.

## .spec.infrastructure.loadBalancers.containerd.registryConfigs

### Properties

| Property                                                                                          | Type      | Required |
|:--------------------------------------------------------------------------------------------------|:----------|:---------|
| [insecureSkipVerify](#specinfrastructureloadbalancerscontainerdregistryconfigsinsecureskipverify) | `boolean` | Optional |
| [mirrorEndpoint](#specinfrastructureloadbalancerscontainerdregistryconfigsmirrorendpoint)         | `array`   | Optional |
| [password](#specinfrastructureloadbalancerscontainerdregistryconfigspassword)                     | `string`  | Optional |
| [registry](#specinfrastructureloadbalancerscontainerdregistryconfigsregistry)                     | `string`  | Optional |
| [username](#specinfrastructureloadbalancerscontainerdregistryconfigsusername)                     | `string`  | Optional |

### Description

Allows specifying custom configuration for a registry at containerd level. You can set authentication details and mirrors for a registry.
This feature can be used for example to authenticate to a private registry at containerd (container runtime) level, i.e. globally instead of using `imagePullSecrets`. It also can be used to use a mirror for a registry or to enable insecure connections to trusted registries that have self-signed certificates.

## .spec.infrastructure.loadBalancers.containerd.registryConfigs.insecureSkipVerify

### Description

Set to `true` to skip TLS verification (e.g. when using self-signed certificates).

## .spec.infrastructure.loadBalancers.containerd.registryConfigs.mirrorEndpoint

### Description

Array of URLs with the mirrors to use for the registry. Example: `["http://mymirror.tld:8080"]`

## .spec.infrastructure.loadBalancers.containerd.registryConfigs.password

### Description

The password containerd will use to authenticate against the registry.

## .spec.infrastructure.loadBalancers.containerd.registryConfigs.registry

### Description

Registry address on which you would like to configure authentication or mirror(s). Example: `myregistry.tld:5000`

## .spec.infrastructure.loadBalancers.containerd.registryConfigs.username

### Description

The username containerd will use to authenticate against the registry.

## .spec.infrastructure.loadBalancers.containerd.selfmanagedRepositories

### Description

Set to true if you manage the NVIDIA container toolkit's repositories externally and wish to skip their automatic configuration with furyctl. Default is false (furyctl manages repositories automatically).
Notice that containerd itself is installed from binaries and does not use a repository. See `.spec.kubernetes.advanced.airGap` for other download options for containerd.

## .spec.infrastructure.loadBalancers.containerd.stateDir

### Description

The Containerd state directory used in the config.toml file.

## .spec.infrastructure.loadBalancers.containerd.storageDir

### Description

The Containerd storage directory used in the config.toml file.

## .spec.infrastructure.loadBalancers.containerd.systemdDir

### Description

The Containerd systemd service directory used in the config.toml file.

## .spec.infrastructure.loadBalancers.haproxy

### Properties

| Property                                                              | Type     | Required |
|:----------------------------------------------------------------------|:---------|:---------|
| [configuration](#specinfrastructureloadbalancershaproxyconfiguration) | `string` | Optional |
| [image](#specinfrastructureloadbalancershaproxyimage)                 | `string` | Optional |
| [tag](#specinfrastructureloadbalancershaproxytag)                     | `string` | Optional |

### Description

HAProxy container configuration for load balancing.

## .spec.infrastructure.loadBalancers.haproxy.configuration

### Description

Custom HAProxy configuration content. If not provided, a default configuration will be generated for load balancing Kubernetes control plane.

## .spec.infrastructure.loadBalancers.haproxy.image

### Description

Container image for HAProxy. Example: docker.io/library/haproxy

## .spec.infrastructure.loadBalancers.haproxy.tag

### Description

Container tag for HAProxy. Example: 2.8-alpine

## .spec.infrastructure.loadBalancers.keepalived

### Properties

| Property                                                                     | Type      | Required |
|:-----------------------------------------------------------------------------|:----------|:---------|
| [enabled](#specinfrastructureloadbalancerskeepalivedenabled)                 | `boolean` | Required |
| [interface](#specinfrastructureloadbalancerskeepalivedinterface)             | `string`  | Optional |
| [ip](#specinfrastructureloadbalancerskeepalivedip)                           | `string`  | Optional |
| [passphrase](#specinfrastructureloadbalancerskeepalivedpassphrase)           | `string`  | Optional |
| [virtualRouterId](#specinfrastructureloadbalancerskeepalivedvirtualrouterid) | `string`  | Optional |

### Description

This section allows to configure a floating Virtual IP between the nodes via Keepalived. This can be used to provide high availability between 2 or more nodes.

## .spec.infrastructure.loadBalancers.keepalived.enabled

### Description

Set to install keepalived with a floating virtual IP shared between the load balancer hosts for a deployment in High Availability.

## .spec.infrastructure.loadBalancers.keepalived.interface

### Description

Name of the network interface where to bind the Keepalived virtual IP.

## .spec.infrastructure.loadBalancers.keepalived.ip

### Description

The Virtual floating IP for Keepalived

## .spec.infrastructure.loadBalancers.keepalived.passphrase

### Description

Password for accessing vrrpd. Make it unique between Keepalived clusters.

### Constraints

**maximum length**: the maximum number of characters for this string is: `8`

## .spec.infrastructure.loadBalancers.keepalived.virtualRouterId

### Description

The virtual router ID of Keepalived, an arbitrary unique number from 1 to 255 used to differentiate multiple instances of vrrpd running on the same network interface and address family and multicast/unicast (and hence same socket).

## .spec.infrastructure.loadBalancers.members

### Properties

| Property                                                    | Type     | Required |
|:------------------------------------------------------------|:---------|:---------|
| [hostname](#specinfrastructureloadbalancersmembershostname) | `string` | Required |
| [ip](#specinfrastructureloadbalancersmembersip)             | `string` | Optional |

### Description

A member node reference with optional IP override.

### Constraints

**minimum number of items**: the minimum number of items for this array is: `1`

## .spec.infrastructure.loadBalancers.members.hostname

### Description

Hostname that must match an infrastructure node. Example: ctrl01.k8s.example.com

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.infrastructure.loadBalancers.members.ip

### Description

Optional IP address. If not specified, it is inferred from the node's network configuration.

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)\.){3}(25[0-5]|(2[0-4]|1\d|[1-9]|)\d)$
```

[try pattern](https://regexr.com/?expression=^\(\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)\.\){3}\(25[0-5]|\(2[0-4]|1\d|[1-9]|\)\d\)$)

## .spec.infrastructure.nodes

### Properties

| Property                                                     | Type     | Required |
|:-------------------------------------------------------------|:---------|:---------|
| [arch](#specinfrastructurenodesarch)                         | `string` | Optional |
| [hostname](#specinfrastructurenodeshostname)                 | `string` | Required |
| [kernelParameters](#specinfrastructurenodeskernelparameters) | `array`  | Optional |
| [macAddress](#specinfrastructurenodesmacaddress)             | `string` | Required |
| [network](#specinfrastructurenodesnetwork)                   | `object` | Required |
| [passwd](#specinfrastructurenodespasswd)                     | `object` | Optional |
| [storage](#specinfrastructurenodesstorage)                   | `object` | Required |
| [systemd](#specinfrastructurenodessystemd)                   | `object` | Optional |

### Description

Definition of a bare metal node with storage, network, and hardware configuration.

### Constraints

**minimum number of items**: the minimum number of items for this array is: `1`

## .spec.infrastructure.nodes.arch

### Description

CPU architecture for the node. Determines which Flatcar artifacts and sysext packages are downloaded. Supports mixed-architecture clusters where different nodes can run different architectures. Kubernetes automatically labels nodes with kubernetes.io/arch. Examples: x86-64 (Intel/AMD amd64), arm64 (ARM aarch64). See examples/immutable-mixed-arch-example.yaml for mixed-architecture cluster configuration.

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

## .spec.infrastructure.nodes.passwd

### Properties

| Property                                       | Type    | Required |
|:-----------------------------------------------|:--------|:---------|
| [groups](#specinfrastructurenodespasswdgroups) | `array` | Optional |
| [users](#specinfrastructurenodespasswdusers)   | `array` | Optional |

### Description

Describes the desired additions to the passwd database. See https://www.flatcar.org/docs/latest/provisioning/config-transpiler/configuration/

## .spec.infrastructure.nodes.passwd.groups

### Properties

| Property                                                           | Type      | Required |
|:-------------------------------------------------------------------|:----------|:---------|
| [gid](#specinfrastructurenodespasswdgroupsgid)                     | `integer` | Optional |
| [name](#specinfrastructurenodespasswdgroupsname)                   | `string`  | Required |
| [password_hash](#specinfrastructurenodespasswdgroupspassword_hash) | `string`  | Optional |
| [should_exist](#specinfrastructurenodespasswdgroupsshould_exist)   | `boolean` | Optional |
| [system](#specinfrastructurenodespasswdgroupssystem)               | `boolean` | Optional |

### Description

Represents a group to be created in the system.

## .spec.infrastructure.nodes.passwd.groups.gid

### Description

The group ID of the new group.

## .spec.infrastructure.nodes.passwd.groups.name

### Description

The name of the group.

## .spec.infrastructure.nodes.passwd.groups.password_hash

### Description

The hashed password of the new group.

## .spec.infrastructure.nodes.passwd.groups.should_exist

### Description

Whether or not the group with the specified name should exist. If omitted, it defaults to true. If false, then Ignition will delete the specified group.

## .spec.infrastructure.nodes.passwd.groups.system

### Description

Whether or not the group should be a system group. This only has an effect if the group doesn't exist yet.

## .spec.infrastructure.nodes.passwd.users

### Properties

| Property                                                                      | Type      | Required |
|:------------------------------------------------------------------------------|:----------|:---------|
| [gecos](#specinfrastructurenodespasswdusersgecos)                             | `string`  | Optional |
| [groups](#specinfrastructurenodespasswdusersgroups)                           | `array`   | Optional |
| [home_dir](#specinfrastructurenodespasswdusershome_dir)                       | `string`  | Optional |
| [name](#specinfrastructurenodespasswdusersname)                               | `string`  | Required |
| [no_create_home](#specinfrastructurenodespasswdusersno_create_home)           | `boolean` | Optional |
| [no_log_init](#specinfrastructurenodespasswdusersno_log_init)                 | `boolean` | Optional |
| [no_user_group](#specinfrastructurenodespasswdusersno_user_group)             | `boolean` | Optional |
| [password_hash](#specinfrastructurenodespasswduserspassword_hash)             | `string`  | Optional |
| [primary_group](#specinfrastructurenodespasswdusersprimary_group)             | `string`  | Optional |
| [shell](#specinfrastructurenodespasswdusersshell)                             | `string`  | Optional |
| [should_exist](#specinfrastructurenodespasswdusersshould_exist)               | `boolean` | Optional |
| [ssh_authorized_keys](#specinfrastructurenodespasswdusersssh_authorized_keys) | `array`   | Optional |
| [system](#specinfrastructurenodespasswduserssystem)                           | `boolean` | Optional |
| [uid](#specinfrastructurenodespasswdusersuid)                                 | `integer` | Optional |

### Description

Represents a user account to be created in the system.

## .spec.infrastructure.nodes.passwd.users.gecos

### Description

The GECOS field of the account.

## .spec.infrastructure.nodes.passwd.users.groups

### Description

The list of supplementary groups of the account.

## .spec.infrastructure.nodes.passwd.users.home_dir

### Description

The home directory of the account.

## .spec.infrastructure.nodes.passwd.users.name

### Description

The username for the account.

## .spec.infrastructure.nodes.passwd.users.no_create_home

### Description

Whether or not to create the user's home directory. This only has an effect if the account doesn't exist yet.

## .spec.infrastructure.nodes.passwd.users.no_log_init

### Description

Whether or not to add the user to the lastlog and faillog databases. This only has an effect if the account doesn't exist yet.

## .spec.infrastructure.nodes.passwd.users.no_user_group

### Description

Whether or not to create a group with the same name as the user. This only has an effect if the account doesn't exist yet.

## .spec.infrastructure.nodes.passwd.users.password_hash

### Description

The hashed password for the account.

## .spec.infrastructure.nodes.passwd.users.primary_group

### Description

The name of the primary group of the account.

## .spec.infrastructure.nodes.passwd.users.shell

### Description

The login shell of the new account.

## .spec.infrastructure.nodes.passwd.users.should_exist

### Description

Whether or not the user with the specified name should exist. If omitted, it defaults to true. If false, then Ignition will delete the specified user.

## .spec.infrastructure.nodes.passwd.users.ssh_authorized_keys

### Description

A list of SSH keys to be added as an SSH key fragment at `.ssh/authorized_keys.d/ignition` in the user's home directory. All SSH keys must be unique.

## .spec.infrastructure.nodes.passwd.users.system

### Description

Whether or not this account should be a system account. This only has an effect if the account doesn't exist yet.

## .spec.infrastructure.nodes.passwd.users.uid

### Description

The user ID of the account.

## .spec.infrastructure.nodes.storage

### Properties

| Property                                                          | Type     | Required |
|:------------------------------------------------------------------|:---------|:---------|
| [additionalDisks](#specinfrastructurenodesstorageadditionaldisks) | `array`  | Optional |
| [directories](#specinfrastructurenodesstoragedirectories)         | `array`  | Optional |
| [files](#specinfrastructurenodesstoragefiles)                     | `array`  | Optional |
| [installDisk](#specinfrastructurenodesstorageinstalldisk)         | `string` | Required |
| [links](#specinfrastructurenodesstoragelinks)                     | `array`  | Optional |

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

## .spec.infrastructure.nodes.storage.directories

### Properties

| Property                                                         | Type      | Required |
|:-----------------------------------------------------------------|:----------|:---------|
| [group](#specinfrastructurenodesstoragedirectoriesgroup)         | `object`  | Optional |
| [mode](#specinfrastructurenodesstoragedirectoriesmode)           | `integer` | Optional |
| [overwrite](#specinfrastructurenodesstoragedirectoriesoverwrite) | `boolean` | Optional |
| [path](#specinfrastructurenodesstoragedirectoriespath)           | `string`  | Required |
| [user](#specinfrastructurenodesstoragedirectoriesuser)           | `object`  | Optional |

### Description

Represents a directory to be created on the filesystem. See Butane Flatcar v1.1.0 spec.

## .spec.infrastructure.nodes.storage.directories.group

### Properties

| Property                                                    | Type      | Required |
|:------------------------------------------------------------|:----------|:---------|
| [id](#specinfrastructurenodesstoragedirectoriesgroupid)     | `integer` | Optional |
| [name](#specinfrastructurenodesstoragedirectoriesgroupname) | `string`  | Optional |

### Description

The group of the directory.

## .spec.infrastructure.nodes.storage.directories.group.id

### Description

The group ID of the owner.

## .spec.infrastructure.nodes.storage.directories.group.name

### Description

The group name of the owner.

## .spec.infrastructure.nodes.storage.directories.mode

### Description

The directory's permission mode (decimal). Note that the mode must be properly specified as a decimal value (i.e. 0o755 -> 493). Example: 493 means 0755.

## .spec.infrastructure.nodes.storage.directories.overwrite

### Description

Whether to delete preexisting nodes at the path. If overwrite is false and a directory already exists at the path, Ignition will only set its permissions. Defaults to false.

## .spec.infrastructure.nodes.storage.directories.path

### Description

The absolute path to the directory.

## .spec.infrastructure.nodes.storage.directories.user

### Properties

| Property                                                   | Type      | Required |
|:-----------------------------------------------------------|:----------|:---------|
| [id](#specinfrastructurenodesstoragedirectoriesuserid)     | `integer` | Optional |
| [name](#specinfrastructurenodesstoragedirectoriesusername) | `string`  | Optional |

### Description

The user of the directory.

## .spec.infrastructure.nodes.storage.directories.user.id

### Description

The user ID of the owner.

## .spec.infrastructure.nodes.storage.directories.user.name

### Description

The username of the owner.

## .spec.infrastructure.nodes.storage.files

### Properties

| Property                                                   | Type      | Required |
|:-----------------------------------------------------------|:----------|:---------|
| [append](#specinfrastructurenodesstoragefilesappend)       | `array`   | Optional |
| [contents](#specinfrastructurenodesstoragefilescontents)   | `object`  | Optional |
| [group](#specinfrastructurenodesstoragefilesgroup)         | `object`  | Optional |
| [mode](#specinfrastructurenodesstoragefilesmode)           | `integer` | Optional |
| [overwrite](#specinfrastructurenodesstoragefilesoverwrite) | `boolean` | Optional |
| [path](#specinfrastructurenodesstoragefilespath)           | `string`  | Required |
| [user](#specinfrastructurenodesstoragefilesuser)           | `object`  | Optional |

### Description

Represents a file to be created on the filesystem.

## .spec.infrastructure.nodes.storage.files.append

### Properties

| Property                                                               | Type     | Required |
|:-----------------------------------------------------------------------|:---------|:---------|
| [compression](#specinfrastructurenodesstoragefilesappendcompression)   | `string` | Optional |
| [http_headers](#specinfrastructurenodesstoragefilesappendhttp_headers) | `array`  | Optional |
| [inline](#specinfrastructurenodesstoragefilesappendinline)             | `string` | Optional |
| [local](#specinfrastructurenodesstoragefilesappendlocal)               | `string` | Optional |
| [source](#specinfrastructurenodesstoragefilesappendsource)             | `string` | Optional |
| [verification](#specinfrastructurenodesstoragefilesappendverification) | `object` | Optional |

### Description

List of contents to be appended to the file. Follows the same structure as contents.

## .spec.infrastructure.nodes.storage.files.append.compression

### Description

The type of compression used on the contents (null or gzip).

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value  |
|:-------|
|`"gzip"`|

## .spec.infrastructure.nodes.storage.files.append.http_headers

### Properties

| Property                                                             | Type     | Required |
|:---------------------------------------------------------------------|:---------|:---------|
| [name](#specinfrastructurenodesstoragefilesappendhttp_headersname)   | `string` | Required |
| [value](#specinfrastructurenodesstoragefilesappendhttp_headersvalue) | `string` | Required |

### Description

A list of HTTP headers to be added to the request. Available for http and https source schemes only.

## .spec.infrastructure.nodes.storage.files.append.http_headers.name

### Description

The header name.

## .spec.infrastructure.nodes.storage.files.append.http_headers.value

### Description

The header contents.

## .spec.infrastructure.nodes.storage.files.append.inline

### Description

The contents to append. Mutually exclusive with source and local.

## .spec.infrastructure.nodes.storage.files.append.local

### Description

A local path to the contents to append, relative to the directory specified by the --files-dir command-line argument. Mutually exclusive with source and inline.

## .spec.infrastructure.nodes.storage.files.append.source

### Description

The URL of the contents to append. Supported schemes are http, https, tftp, s3, gs, and data. Mutually exclusive with inline and local.

## .spec.infrastructure.nodes.storage.files.append.verification

### Properties

| Property                                                           | Type     | Required |
|:-------------------------------------------------------------------|:---------|:---------|
| [hash](#specinfrastructurenodesstoragefilesappendverificationhash) | `string` | Optional |

### Description

Options related to the verification of the appended contents.

## .spec.infrastructure.nodes.storage.files.append.verification.hash

### Description

The hash of the content, in the form <type>-<value> where type is either sha512 or sha256.

## .spec.infrastructure.nodes.storage.files.contents

### Properties

| Property                                                                 | Type     | Required |
|:-------------------------------------------------------------------------|:---------|:---------|
| [compression](#specinfrastructurenodesstoragefilescontentscompression)   | `string` | Optional |
| [http_headers](#specinfrastructurenodesstoragefilescontentshttp_headers) | `array`  | Optional |
| [inline](#specinfrastructurenodesstoragefilescontentsinline)             | `string` | Optional |
| [local](#specinfrastructurenodesstoragefilescontentslocal)               | `string` | Optional |
| [source](#specinfrastructurenodesstoragefilescontentssource)             | `string` | Optional |
| [verification](#specinfrastructurenodesstoragefilescontentsverification) | `object` | Optional |

### Description

Options related to the contents of the file.

## .spec.infrastructure.nodes.storage.files.contents.compression

### Description

The type of compression used on the contents (null or gzip). Compression cannot be used with S3.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value  |
|:-------|
|`"gzip"`|

## .spec.infrastructure.nodes.storage.files.contents.http_headers

### Properties

| Property                                                               | Type     | Required |
|:-----------------------------------------------------------------------|:---------|:---------|
| [name](#specinfrastructurenodesstoragefilescontentshttp_headersname)   | `string` | Required |
| [value](#specinfrastructurenodesstoragefilescontentshttp_headersvalue) | `string` | Required |

### Description

A list of HTTP headers to be added to the request. Available for http and https source schemes only.

## .spec.infrastructure.nodes.storage.files.contents.http_headers.name

### Description

The header name.

## .spec.infrastructure.nodes.storage.files.contents.http_headers.value

### Description

The header contents.

## .spec.infrastructure.nodes.storage.files.contents.inline

### Description

The contents of the file. Mutually exclusive with source and local.

## .spec.infrastructure.nodes.storage.files.contents.local

### Description

A local path to the contents of the file, relative to the directory specified by the --files-dir command-line argument. Mutually exclusive with source and inline.

## .spec.infrastructure.nodes.storage.files.contents.source

### Description

The URL of the file contents. Supported schemes are http, https, tftp, s3, gs, and data. When using http, it is advisable to use the verification option. Mutually exclusive with inline and local.

## .spec.infrastructure.nodes.storage.files.contents.verification

### Properties

| Property                                                             | Type     | Required |
|:---------------------------------------------------------------------|:---------|:---------|
| [hash](#specinfrastructurenodesstoragefilescontentsverificationhash) | `string` | Optional |

### Description

Options related to the verification of the file contents.

## .spec.infrastructure.nodes.storage.files.contents.verification.hash

### Description

The hash of the content, in the form <type>-<value> where type is either sha512 or sha256. Example: sha256-abcd1234...

## .spec.infrastructure.nodes.storage.files.group

### Properties

| Property                                              | Type      | Required |
|:------------------------------------------------------|:----------|:---------|
| [id](#specinfrastructurenodesstoragefilesgroupid)     | `integer` | Optional |
| [name](#specinfrastructurenodesstoragefilesgroupname) | `string`  | Optional |

### Description

Specifies the file's group.

## .spec.infrastructure.nodes.storage.files.group.id

### Description

The group ID of the group.

## .spec.infrastructure.nodes.storage.files.group.name

### Description

The group name of the group.

## .spec.infrastructure.nodes.storage.files.mode

### Description

The file's permission mode (in octal, e.g. 0644). Setuid/setgid/sticky bits are not supported. If not specified, the permission mode for files defaults to 0644 or the existing file's permissions if overwrite is false and a file already exists.

## .spec.infrastructure.nodes.storage.files.overwrite

### Description

Whether to delete preexisting nodes at the path. Contents must be specified if overwrite is true. Defaults to false.

## .spec.infrastructure.nodes.storage.files.path

### Description

The absolute path to the file.

## .spec.infrastructure.nodes.storage.files.user

### Properties

| Property                                             | Type      | Required |
|:-----------------------------------------------------|:----------|:---------|
| [id](#specinfrastructurenodesstoragefilesuserid)     | `integer` | Optional |
| [name](#specinfrastructurenodesstoragefilesusername) | `string`  | Optional |

### Description

Specifies the file's owner.

## .spec.infrastructure.nodes.storage.files.user.id

### Description

The user ID of the owner.

## .spec.infrastructure.nodes.storage.files.user.name

### Description

The user name of the owner.

## .spec.infrastructure.nodes.storage.installDisk

### Description

Unix device path. Example: /dev/sda, /dev/nvme0n1

### Constraints

**pattern**: the string must match the following regular expression:

```regexp
^/dev/[a-zA-Z0-9/]+$
```

[try pattern](https://regexr.com/?expression=^\/dev\/[a-zA-Z0-9\/]%2B$)

## .spec.infrastructure.nodes.storage.links

### Properties

| Property                                                   | Type      | Required |
|:-----------------------------------------------------------|:----------|:---------|
| [group](#specinfrastructurenodesstoragelinksgroup)         | `object`  | Optional |
| [hard](#specinfrastructurenodesstoragelinkshard)           | `boolean` | Optional |
| [overwrite](#specinfrastructurenodesstoragelinksoverwrite) | `boolean` | Optional |
| [path](#specinfrastructurenodesstoragelinkspath)           | `string`  | Required |
| [target](#specinfrastructurenodesstoragelinkstarget)       | `string`  | Required |
| [user](#specinfrastructurenodesstoragelinksuser)           | `object`  | Optional |

### Description

Represents a symbolic or hard link to be created.

## .spec.infrastructure.nodes.storage.links.group

### Properties

| Property                                              | Type      | Required |
|:------------------------------------------------------|:----------|:---------|
| [id](#specinfrastructurenodesstoragelinksgroupid)     | `integer` | Optional |
| [name](#specinfrastructurenodesstoragelinksgroupname) | `string`  | Optional |

### Description

Specifies the group for a symbolic link. Ignored for hard links.

## .spec.infrastructure.nodes.storage.links.group.id

### Description

The group ID of the group.

## .spec.infrastructure.nodes.storage.links.group.name

### Description

The group name of the group.

## .spec.infrastructure.nodes.storage.links.hard

### Description

A symbolic link is created if this is false, a hard one if this is true.

## .spec.infrastructure.nodes.storage.links.overwrite

### Description

Whether to delete preexisting nodes at the path. If overwrite is false and a matching link exists at the path, Ignition will only set the owner and group. Defaults to false.

## .spec.infrastructure.nodes.storage.links.path

### Description

The absolute path to the link.

## .spec.infrastructure.nodes.storage.links.target

### Description

The target path of the link.

## .spec.infrastructure.nodes.storage.links.user

### Properties

| Property                                             | Type      | Required |
|:-----------------------------------------------------|:----------|:---------|
| [id](#specinfrastructurenodesstoragelinksuserid)     | `integer` | Optional |
| [name](#specinfrastructurenodesstoragelinksusername) | `string`  | Optional |

### Description

Specifies the owner for a symbolic link. Ignored for hard links.

## .spec.infrastructure.nodes.storage.links.user.id

### Description

The user ID of the owner.

## .spec.infrastructure.nodes.storage.links.user.name

### Description

The user name of the owner.

## .spec.infrastructure.nodes.systemd

### Properties

| Property                                      | Type    | Required |
|:----------------------------------------------|:--------|:---------|
| [units](#specinfrastructurenodessystemdunits) | `array` | Optional |

### Description

Describes the desired state of the systemd units.

## .spec.infrastructure.nodes.systemd.units

### Description

the list of systemd units. Every unit must have a unique name.

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

| Property                                               | Type     | Required |
|:-------------------------------------------------------|:---------|:---------|
| [privateKeyPath](#specinfrastructuresshprivatekeypath) | `string` | Optional |
| [publicKeyPath](#specinfrastructuresshpublickeypath)   | `string` | Optional |
| [username](#specinfrastructuresshusername)             | `string` | Required |

### Description

SSH credentials for node access.

## .spec.infrastructure.ssh.privateKeyPath

### Description

Path to the SSH private key. Example: ~/.ssh/id_ed25519_production

## .spec.infrastructure.ssh.publicKeyPath

### Description

Path to the SSH public key. If not specified, defaults to privateKeyPath + '.pub' (or keyPath + '.pub' if using deprecated keyPath). Example: ~/.ssh/id_ed25519_production.pub

## .spec.infrastructure.ssh.username

### Description

SSH username. Example: core

### Constraints

**minimum length**: the minimum number of characters for this string is: `1`

## .spec.kubernetes

### Properties

| Property                                    | Type     | Required |
|:--------------------------------------------|:---------|:---------|
| [advanced](#speckubernetesadvanced)         | `object` | Optional |
| [controlPlane](#speckubernetescontrolplane) | `object` | Required |
| [etcd](#speckubernetesetcd)                 | `object` | Optional |
| [networking](#speckubernetesnetworking)     | `object` | Required |
| [nodeGroups](#speckubernetesnodegroups)     | `array`  | Optional |
| [pkiPath](#speckubernetespkipath)           | `string` | Optional |
| [version](#speckubernetesversion)           | `string` | Optional |

### Description

Kubernetes cluster configuration including control plane, etcd, and worker nodes.

## .spec.kubernetes.advanced

### Properties

| Property                                                            | Type     | Required |
|:--------------------------------------------------------------------|:---------|:---------|
| [apiServer](#speckubernetesadvancedapiserver)                       | `object` | Optional |
| [cloud](#speckubernetesadvancedcloud)                               | `object` | Optional |
| [containerd](#speckubernetesadvancedcontainerd)                     | `object` | Optional |
| [controllerManager](#speckubernetesadvancedcontrollermanager)       | `object` | Optional |
| [encryption](#speckubernetesadvancedencryption)                     | `object` | Optional |
| [eventRateLimits](#speckubernetesadvancedeventratelimits)           | `array`  | Optional |
| [kubeProxy](#speckubernetesadvancedkubeproxy)                       | `object` | Optional |
| [kubeletConfiguration](#speckubernetesadvancedkubeletconfiguration) | `object` | Optional |
| [oidc](#speckubernetesadvancedoidc)                                 | `object` | Optional |
| [registry](#speckubernetesadvancedregistry)                         | `string` | Optional |
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
| [config](#speckubernetesadvancedcloudconfig)     | `string` | Optional |
| [provider](#speckubernetesadvancedcloudprovider) | `string` | Optional |

### Description

Cloud provider integration. Ref: https://kubernetes.io/docs/concepts/architecture/cloud-controller/

## .spec.kubernetes.advanced.cloud.config

### Description

Sets cloud config for the Kubelet

## .spec.kubernetes.advanced.cloud.provider

### Description

Sets the cloud provider for the Kubelet

## .spec.kubernetes.advanced.containerd

### Properties

| Property                                                                                                  | Type      | Required |
|:----------------------------------------------------------------------------------------------------------|:----------|:---------|
| [debugLevel](#speckubernetesadvancedcontainerddebuglevel)                                                 | `string`  | Optional |
| [deviceOwnershipFromSecurityContext](#speckubernetesadvancedcontainerddeviceownershipfromsecuritycontext) | `boolean` | Optional |
| [grpcMaxRecvMessageSize](#speckubernetesadvancedcontainerdgrpcmaxrecvmessagesize)                         | `integer` | Optional |
| [grpcMaxSendMessageSize](#speckubernetesadvancedcontainerdgrpcmaxsendmessagesize)                         | `integer` | Optional |
| [maxContainerLogLineSize](#speckubernetesadvancedcontainerdmaxcontainerloglinesize)                       | `integer` | Optional |
| [metricsAddress](#speckubernetesadvancedcontainerdmetricsaddress)                                         | `string`  | Optional |
| [metricsGrpcHistogram](#speckubernetesadvancedcontainerdmetricsgrpchistogram)                             | `boolean` | Optional |
| [oomScore](#speckubernetesadvancedcontainerdoomscore)                                                     | `integer` | Optional |
| [registryConfigs](#speckubernetesadvancedcontainerdregistryconfigs)                                       | `array`   | Optional |
| [selfmanagedRepositories](#speckubernetesadvancedcontainerdselfmanagedrepositories)                       | `boolean` | Optional |
| [stateDir](#speckubernetesadvancedcontainerdstatedir)                                                     | `string`  | Optional |
| [storageDir](#speckubernetesadvancedcontainerdstoragedir)                                                 | `string`  | Optional |
| [systemdDir](#speckubernetesadvancedcontainerdsystemddir)                                                 | `string`  | Optional |

### Description

Advanced configuration for containerd

## .spec.kubernetes.advanced.containerd.debugLevel

### Description

The Containerd debug level used in the config.toml file.

## .spec.kubernetes.advanced.containerd.deviceOwnershipFromSecurityContext

### Description

Set to true to apply device ownership from the container runtime's security context instead of the host's defaults, used in the config.toml file.

## .spec.kubernetes.advanced.containerd.grpcMaxRecvMessageSize

### Description

The Containerd gRPC maximum receive message size in bytes used in the config.toml file.

## .spec.kubernetes.advanced.containerd.grpcMaxSendMessageSize

### Description

The Containerd gRPC maximum send message size in bytes used in the config.toml file.

## .spec.kubernetes.advanced.containerd.maxContainerLogLineSize

### Description

The maximum container log line size in bytes used in the config.toml file.

## .spec.kubernetes.advanced.containerd.metricsAddress

### Description

The Containerd metrics address used in the config.toml file.

## .spec.kubernetes.advanced.containerd.metricsGrpcHistogram

### Description

Enable Containerd metrics gRPC histogram in the config.toml file.

## .spec.kubernetes.advanced.containerd.oomScore

### Description

The Containerd OOM score adjustment used in the config.toml file.

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

## .spec.kubernetes.advanced.containerd.selfmanagedRepositories

### Description

Set to true if you manage the NVIDIA container toolkit's repositories externally and wish to skip their automatic configuration with furyctl. Default is false (furyctl manages repositories automatically).
Notice that containerd itself is installed from binaries and does not use a repository. See `.spec.kubernetes.advanced.airGap` for other download options for containerd.

## .spec.kubernetes.advanced.containerd.stateDir

### Description

The Containerd state directory used in the config.toml file.

## .spec.kubernetes.advanced.containerd.storageDir

### Description

The Containerd storage directory used in the config.toml file.

## .spec.kubernetes.advanced.containerd.systemdDir

### Description

The Containerd systemd service directory used in the config.toml file.

## .spec.kubernetes.advanced.controllerManager

### Properties

| Property                                                           | Type      | Required |
|:-------------------------------------------------------------------|:----------|:---------|
| [gcThreshold](#speckubernetesadvancedcontrollermanagergcthreshold) | `integer` | Optional |

### Description

Advanced configuration for the controller-manager.

## .spec.kubernetes.advanced.controllerManager.gcThreshold

### Description

Maximum number of terminated Pods retained by the controller-manager before automatic deletion.

## .spec.kubernetes.advanced.encryption

### Properties

| Property                                                                          | Type     | Required |
|:----------------------------------------------------------------------------------|:---------|:---------|
| [configuration](#speckubernetesadvancedencryptionconfiguration)                   | `string` | Optional |
| [tlsCipherSuites](#speckubernetesadvancedencryptiontlsciphersuites)               | `array`  | Optional |
| [tlsCipherSuitesKubelet](#speckubernetesadvancedencryptiontlsciphersuiteskubelet) | `array`  | Optional |

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

The TLS cipher suites to use for etcd and kubeadm static pods. Example:
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
.

## .spec.kubernetes.advanced.encryption.tlsCipherSuitesKubelet

### Description

The TLS cipher suites to use for the kubelet. Example:
```yaml
tlsCipherSuitesKubelet:
  - "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
  - "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
  - "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384"
 - "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305"
  - "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305"
  - "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
```
. NOTE: to customize the TLS cipher suites of the kubelet, set only this field - do not configure them under the `KubeletConfiguration`.

## .spec.kubernetes.advanced.eventRateLimits

### Properties

| Property                                                     | Type      | Required |
|:-------------------------------------------------------------|:----------|:---------|
| [burst](#speckubernetesadvancedeventratelimitsburst)         | `integer` | Required |
| [cacheSize](#speckubernetesadvancedeventratelimitscachesize) | `integer` | Optional |
| [qps](#speckubernetesadvancedeventratelimitsqps)             | `integer` | Required |
| [type](#speckubernetesadvancedeventratelimitstype)           | `string`  | Required |

### Description

Configures the limits of the API Server's EventRateLimit plugin. Each item represents a bucket (Server, Namespace, User, etc).

## .spec.kubernetes.advanced.eventRateLimits.burst

### Description

Maximum allowed burst for this bucket type.

## .spec.kubernetes.advanced.eventRateLimits.cacheSize

### Description

Maximum number of cached objects for this bucket. Only for certain types like Namespace or User.

## .spec.kubernetes.advanced.eventRateLimits.qps

### Description

Maximum allowed queries per second (QPS) for this bucket type.

## .spec.kubernetes.advanced.eventRateLimits.type

### Description

Type of limit to apply (Server, Namespace, User, SourceAndObject).

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value             |
|:------------------|
|`"Server"`         |
|`"Namespace"`      |
|`"User"`           |
|`"SourceAndObject"`|

## .spec.kubernetes.advanced.kubeProxy

### Properties

| Property                                                                     | Type     | Required |
|:-----------------------------------------------------------------------------|:---------|:---------|
| [additionalProperties](#speckubernetesadvancedkubeproxyadditionalproperties) | `object` | Optional |
| [type](#speckubernetesadvancedkubeproxytype)                                 | `string` | Optional |

### Description

Configuration for the kube-proxy component.

## .spec.kubernetes.advanced.kubeProxy.additionalProperties

## .spec.kubernetes.advanced.kubeProxy.type

### Description

The operating mode for kube-proxy. `none` skips kube-proxy installation and configures the CNI accordingly (Cilium in kube-proxy-replacement mode, Calico in eBPF mode).  `nftables` (default) installs kube-proxy in nftables mode.

NOTE: Changing the `type` after the cluster has been created is not currently supported.

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value      |
|:-----------|
|`"none"`    |
|`"nftables"`|

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

## .spec.kubernetes.controlPlane

### Properties

| Property                                                                | Type     | Required |
|:------------------------------------------------------------------------|:---------|:---------|
| [address](#speckubernetescontrolplaneaddress)                           | `string` | Required |
| [annotations](#speckubernetescontrolplaneannotations)                   | `object` | Optional |
| [keepalived](#speckubernetescontrolplanekeepalived)                     | `object` | Optional |
| [kubeletConfiguration](#speckubernetescontrolplanekubeletconfiguration) | `object` | Optional |
| [labels](#speckubernetescontrolplanelabels)                             | `object` | Optional |
| [members](#speckubernetescontrolplanemembers)                           | `array`  | Required |
| [taints](#speckubernetescontrolplanetaints)                             | `array`  | Optional |

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

## .spec.kubernetes.controlPlane.annotations

### Description

Optional additional Kubernetes annotations that will be added to the control-plane nodes. Follows Kubernetes annotations format. **Existing annotations with the same key will be overwritten**.

## .spec.kubernetes.controlPlane.keepalived

### Properties

| Property                                                                | Type      | Required |
|:------------------------------------------------------------------------|:----------|:---------|
| [enabled](#speckubernetescontrolplanekeepalivedenabled)                 | `boolean` | Required |
| [interface](#speckubernetescontrolplanekeepalivedinterface)             | `string`  | Optional |
| [ip](#speckubernetescontrolplanekeepalivedip)                           | `string`  | Optional |
| [passphrase](#speckubernetescontrolplanekeepalivedpassphrase)           | `string`  | Optional |
| [virtualRouterId](#speckubernetescontrolplanekeepalivedvirtualrouterid) | `string`  | Optional |

### Description

This section allows to configure a floating Virtual IP between the nodes via Keepalived. This can be used to provide high availability between 2 or more nodes.

## .spec.kubernetes.controlPlane.keepalived.enabled

### Description

Set to install keepalived with a floating virtual IP shared between the load balancer hosts for a deployment in High Availability.

## .spec.kubernetes.controlPlane.keepalived.interface

### Description

Name of the network interface where to bind the Keepalived virtual IP.

## .spec.kubernetes.controlPlane.keepalived.ip

### Description

The Virtual floating IP for Keepalived

## .spec.kubernetes.controlPlane.keepalived.passphrase

### Description

Password for accessing vrrpd. Make it unique between Keepalived clusters.

### Constraints

**maximum length**: the maximum number of characters for this string is: `8`

## .spec.kubernetes.controlPlane.keepalived.virtualRouterId

### Description

The virtual router ID of Keepalived, an arbitrary unique number from 1 to 255 used to differentiate multiple instances of vrrpd running on the same network interface and address family and multicast/unicast (and hence same socket).

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

## .spec.kubernetes.controlPlane.labels

### Description

Optional additional Kubernetes labels that will be added to the control-plane nodes. Follows Kubernetes labels format.

Note: **Existing labels with the same key will be overwritten** and the label setting the `control-plane` role cannot be deleted.

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

## .spec.kubernetes.controlPlane.taints

### Properties

| Property                                          | Type     | Required |
|:--------------------------------------------------|:---------|:---------|
| [effect](#speckubernetescontrolplanetaintseffect) | `string` | Required |
| [key](#speckubernetescontrolplanetaintskey)       | `string` | Required |
| [value](#speckubernetescontrolplanetaintsvalue)   | `string` | Required |

### Description

Kubernetes taints for the control-plane nodes, follows Kubernetes taints format. Default is `node-role.kubernetes.io/control-plane:NoSchedule`.

Example:

```yaml
- effect: NoSchedule
  key: node.kubernetes.io/role
  value: control-plane
```

NOTE: Setting an empty list will remove the default control-plane taint.

NOTE2: Takes effect only at cluster creation time.

## .spec.kubernetes.controlPlane.taints.effect

### Constraints

**enum**: the value of this property must be equal to one of the following string values:

| Value              |
|:-------------------|
|`"NoSchedule"`      |
|`"PreferNoSchedule"`|
|`"NoExecute"`       |

## .spec.kubernetes.controlPlane.taints.key

## .spec.kubernetes.controlPlane.taints.value

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

## .spec.kubernetes.pkiPath

### Description

Path to the PKI directory where to find the certificates and keys for Kubernetes Control Plane and etcd. Must have the `master` and `etcd` folders inside.

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

## .spec.toolsConfiguration

### Properties

| Property                                  | Type     | Required |
|:------------------------------------------|:---------|:---------|
| [ansible](#spectoolsconfigurationansible) | `object` | Optional |

### Description

Configuration for tools used by furyctl.

## .spec.toolsConfiguration.ansible

### Properties

| Property                                                             | Type     | Required |
|:---------------------------------------------------------------------|:---------|:---------|
| [config](#spectoolsconfigurationansibleconfig)                       | `string` | Optional |
| [pythonInterpreter](#spectoolsconfigurationansiblepythoninterpreter) | `string` | Optional |

### Description

Ansible configuration.

## .spec.toolsConfiguration.ansible.config

### Description

Additional content to append to the generated ansible.cfg file.

## .spec.toolsConfiguration.ansible.pythonInterpreter

### Description

Path to the Python interpreter to be used by Ansible on the remote nodes. Example: /usr/bin/python3

