# SIGHUP Distribution Release vTBD

Welcome to the latest release of SD maintained by SIGHUP by ReeVo team.

## Bug fixes 🐞

- [[#637](https://github.com/sighupio/distribution/pull/637)] When `spec.distribution.common.networkPoliciesEnabled` is `true`, the Headlamp dashboard could not reach Prometheus to show the metrics in the UI because of a missing network policy.
- In the `OnPremises` and `Immutable` kinds, the validation accepted `spec.distribution.modules.auth.oidcKubernetesAuth.enabled: true` without `auth.dex` and `auth.baseDomain` when `auth.provider.type` is `none` or `basicAuth`. With this configuration, Dex does not start and the Dex and Gangplank ingresses get hosts that are not valid. The validation now requires `auth.dex` and `auth.baseDomain` when `oidcKubernetesAuth.enabled` is `true`, for all the provider types.
