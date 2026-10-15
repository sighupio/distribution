# Templates Tests suite

This folder contains a test suite for asserting that the distribution templates are generating the expected output.

Inside this folder you will find a subfolder for each SIGHUP Distribution provider, and inside each subfolder you will find the tests cases for that provider.

The tests are executed as follows:

1. A `baseline` folder is created for each test case, containing the expected output.
2. The test case is executed, and the output is compared to the `baseline` folder.
3. If the output does not match the `baseline`, the test fails.

## Running the tests

To run the tests, execute the following command:

```
mise run test:templates:regressions
```

## Updating the baseline

If changes to the templates are made, the `baseline` folder for all test cases should be updated to reflect the new output.

Changes to `kfd.yaml` also require a baseline update: every test case that enables Headlamp renders `manifests/utilities/resources/sd-spec.yml`, which contains the distribution and module versions from `kfd.yaml`.

First run the regression tests to ensure the changes are not breaking other parts of the output:

```
mise run test:templates:regressions
```

if the changes are the expected, update the `baseline` folder for all test cases:

```
mise run test:templates:update-baseline
```

## Checks on the `diff.sh` scripts

`furyctl diff` runs the rendered `scripts/diff.sh` of the distribution and plugins phases, and promises that they never write to the cluster. Two more checks guard this promise. CI runs them in the `test-templates-regressions` step, after the regression tests:

```
mise run test:templates:diff-safety
mise run test:templates:plugins-diff-sync
```

- `diff-safety` reads every baseline `scripts/diff.sh` and `templates/plugins/scripts/diff.sh.tpl`. It fails when `$kubectlbin` runs anything other than `get`, when `$kappbin` runs without `--diff-run` or with `-y`/`--yes`, when `kubectl`, `kapp`, `helm` or `helmfile` is called by name or by path (for example `/usr/bin/kubectl apply`) instead of through its `*bin` variable, and when a bin variable is written as `${...}`. It is a text check: the regression tests pin the exact rendered text, so any other change to a `diff.sh` shows up in the baseline diff for review.
- `plugins-diff-sync` compares `templates/plugins/scripts/diff.sh.tpl` with `apply.sh.tpl`, because no baseline covers the plugins templates. The kustomize build line must be the same, the kapp line must be the apply one without `-y` and `-c` plus `--diff-run --json`, the shell escaping of the plugin name and folder must be the same, and `set -e` must come before the first plugin.

Configuration values that end up in a shell command (the registry, the plugin name and folder, the EKS DNS zone names) are escaped in the templates. A plain registry or DNS zone name renders unchanged, so the escaping does not show in the baselines.
