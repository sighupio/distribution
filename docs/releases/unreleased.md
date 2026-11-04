# SIGHUP Distribution Release vTBD

Welcome to the latest release of SD maintained by SIGHUP by ReeVo team.

## Bug fixes 🐞

- [[#637](https://github.com/sighupio/distribution/pull/637)] When `spec.distribution.common.networkPoliciesEnabled` is `true`, the Headlamp dashboard could not reach Prometheus to show the metrics in the UI because of a missing network policy.
- [[#638](https://github.com/sighupio/distribution/pull/638)] When `spec.distribution.common.networkPoliciesEnabled` is `true`, the Headlamp dashboard could not show logs and events, because no network policy let the Kubernetes API server reach Loki or OpenSearch. The `headlamp` namespace now also has its own network policies, like the other SD namespaces.
