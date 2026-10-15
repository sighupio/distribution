# SIGHUP Distribution Release vTBD

Welcome to the latest release of SD maintained by SIGHUP by ReeVo team.

## New features 🌟

- [[#627](https://github.com/sighupio/distribution/pull/627)] The distribution and plugins phases now render a read-only `scripts/diff.sh` next to `scripts/apply.sh`. `furyctl diff` runs it to show which Kubernetes resources an apply would create, update or delete. The script builds the same manifests as `apply.sh` and runs `kapp deploy --diff-run --json`, so it never changes the cluster. The rendered `apply.sh` does not change.

- [[#627](https://github.com/sighupio/distribution/pull/627)] `furyctl diff` also compares the Helm plugins (`spec.plugins.helm`) with `helmfile diff`. Like `helmfile apply`, `helmfile diff` evaluates the Go templates of the helmfile, including `exec`, `readFile` and `env`, in release fields and in `.gotmpl` values files, on the machine that runs furyctl and with the cluster credentials that furyctl uses. So a diff is only read-only for a trusted configuration: run `furyctl diff` only on a `furyctl.yaml` you would also run `furyctl apply` on, and review a proposed configuration before you diff it.

## Bug fixes 🐞

- [[#627](https://github.com/sighupio/distribution/pull/627)] The rendered scripts now escape the configuration values they put into shell commands: `spec.distribution.common.registry` in the image registry `sed` of `scripts/apply.sh` and `scripts/diff.sh`, `spec.plugins.kustomize[].name` and `folder` in the plugins `scripts/apply.sh` and `scripts/diff.sh`, and the EKSCluster public and private DNS zone names in `scripts/delete.sh`. Before, a value with shell syntax (for example a quote, `;` or `$(...)`) ran as a command, and a plugin folder with spaces was split into several arguments. A plain registry or DNS zone name renders exactly as before; the plugin name and folder are now double-quoted.

## Breaking Changes 💔

- [[#627](https://github.com/sighupio/distribution/pull/627)] `templates/distribution/scripts/apply.sh.tpl` now uses the `kfdBuildOutYaml`, `kfdAdditionalKappArgs`, `kfdKappApp` and `kfdKappStrategy` blocks defined in `templates/distribution/_helpers.tpl`. If you replace `_helpers.tpl` with `--distro-patches`, copy these blocks into your version, or the rendering of `apply.sh` and `diff.sh` fails.
