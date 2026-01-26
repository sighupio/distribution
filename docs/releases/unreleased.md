# SIGHUP Distribution Release TBD

Welcome to SD release TBD

The distribution is maintained with ❤️ by the team [SIGHUP by ReeVo](https://sighup.io/).

## New features 🌟

- [[#468](https://github.com/sighupio/distribution/pull/468)] Added OpenTofu as an alternative to Terraform, with compatibility for existing Terraform state files:
  - New `spec.toolsConfiguration.opentofu` field for state backend configuration
  - Under the hood furyctl will use the OpenTofu binary
  - Existing `terraform` configurations continue to work



## Breaking Changes 💔

None, but the `spec.toolsConfiguration.terraform` field is deprecated in favor of `spec.toolsConfiguration.opentofu`
  - Users are encouraged to migrate to `opentofu` configuration
  - The `terraform` field will be removed in a future version

## Migration Guide

If you're currently using Terraform and want to migrate to OpenTofu field:

1. Add the `opentofu` field to your furyctl.yaml file with the same S3 backend:

```yaml
spec:
  toolsConfiguration:
    opentofu:     # Before was terraform
      state:
        s3:
          bucketName: your-bucket-name       # Same as terraform
          keyPrefix: your-key-prefix          # Same as terraform
          region: your-region                 # Same as terraform
```

## Upgrade procedure
Check the [upgrade docs](https://docs.sighup.io/docs/installation/upgrades/) for the steps to upgrade the SIGHUP Distribution from one version to the next using furyctl.
