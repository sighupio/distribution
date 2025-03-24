# SIGHUP Distribution Maintenance Guide

In this document you can find the steps needed to cook a new release of KFD.

Some things to know before starting:

- We maintain the latest 3 "minor" versions of KFD so, when you release a new version, you usually need to actually release 3 new versions. See the [versioning](docs/VERSIONING.md) file for more details if you are not familiar with KFD's versioning.
- Each release of KFD is tightly coupled with a release of `furyctl`. So you'll need to be able to update furyctl too, or ask for help from somebody that can.

Usually, a new release of KFD is triggered by one of these events:

- One or more core modules have been updated (new versions have been released), could be a bug fix or a simple bump of version to add new features.
- A new version with a bug fix or new features of one or more of the installers (on-premises, EKS, etc.) has been released.
- A new feature or a bug fix has been introduced into the template files of the distribution.
- A new release of Kubernetes is out and must be supported (usually triggers all the 3 previous points).

The release is needed to render this updates available to KFD's user base.

## Process

The update process usually involves going back and forward between KFD (this repo) and furyctl.

> [!NOTE]
> Some of the following steps may not apply in some specific cases, for example if you are only releasing a patch version that fixes an issue on the templates, maybe you can skip some steps.

With no further ado, the steps to release a new version are:

### fury-distribution

> [!WARNING]
> If you are releasing a new `x.y.0` version create a `release-vX.<y-1>` branch for the previous release.

1. Create a new branch `feat/vx.y.z` (`v1.29.4`, for example) where to work on.
2. Create the PRs fixing the issues or adding new features to the templates or other files of fury-distribution, test them and merge them.
3. Update the `kfd.yaml` and `Furyfile.yaml` files, bumping the distribution version, adjusting the modules and installers versions where needed.
4. If the distribution schemas have been changed:
   1. If you haven't already, install the needed tools with `make tools-go`.
   2. Generate the new docs with `make generate-docs`.
   3. Generate the go models with `make generate-go-models`
5. Update the CI and e2e tests to point to the new version:
   1. `.drone.yaml`
   2. `tests/e2e-kfddistribution-*.yaml`
   3. `tests/e2e-kfddistribution-upgrades.sh`
   4. `tests/e2e/kfddistribution-upgrades/furyctl-init-cluster-1.29.4.yaml`
6. Update the documentation:
   1. `README.md`
   2. `docs/COMPATIBILITY_MATRIX.md`
   3. `docs/VERSIONING.md`
   4. Write the release notes for the new version (`docs/releases/vx.y.z.md`)
7. Tag a release candidate to trigger all the e2e tests and fix eventual problems

At this point, you'll need to switch to pushing some changes in furyctl

### furyctl

8. Create a new branch for the WIP release like `feat/vx.y.z` (`v0.29.8`, for example)
9. Add the new versions to the `internal/distribution/compatibility.go` file.
10. Add the migration paths to the corresponding kinds in `configs/upgrades/{onpremises,kfddistribution,ekscluster}/`, creating the needed folders for each new version.
11. Update the documentation:
    1. `README.md`.
    2. `docs/COMPATIBLITY_MATRIX.md`.
12. Update the compatibility unit tests with the new versions (`internal/distribution/compatibility_test.go`)
13. Bump the version to the new `fury-distribution` go library that has been released as RC in step `7`.

```bash
go get -u github.com/sighupio/fury-distribution@v1.29.4
go mod tidy
```

14. Tag a release candidate with the changes. This will be used in the e2e tests of the distribution.

### Back to fury-distribution

15. Update the CI's `.drone.yaml` file to use the release candidate for furyctl that you released in step `14`.
16. Update the e2e tests with the new upgrade paths.
17. Tag a new release candidate of the distribution to run the e2e tests using the new upgrade paths and furyctl's RC.
18. After the CI passes and the PR has been approved, merge into `main`
19. Tag the final release and let the CI run again and do the release.
20. **Repeat all the process for the other 2 "minor" versions that need to be updated**, but targeting `release-vx.y` branches instead of `main`.

### Back to furyctl

21. Once KFD new releases are live and the PR with the update to furyctl has been approved, merge and tag the final release.

### Other changes

After the release of the distribution and furyctl have been done, there are some other places that need to be updated to reflect the new releases, in no particular order:

1. Update the quick-start guides in https://github.com/sighupio/fury-getting-started/
2. Update KFD's documentation site with the new versions https://github.com/sighupio/kfd-docs/
