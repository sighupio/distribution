# SIGHUP Distribution Release vTBD

Welcome to the latest release of SD maintained by SIGHUP by ReeVo team.

## Bug fixes 🐞

- [[#637](https://github.com/sighupio/distribution/pull/637)] When `spec.distribution.common.networkPoliciesEnabled` is `true`, the Headlamp dashboard could not reach Prometheus to show the metrics in the UI because of a missing network policy.
- [[#639](https://github.com/sighupio/distribution/pull/639)] When `spec.distribution.common.networkPoliciesEnabled` is `true`, Prometheus could not scrape the Fluentd buffer metrics (port 9533) and the Loki gateway metrics (port 4040) because the network policies did not allow these ports.
