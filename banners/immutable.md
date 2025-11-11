# Immutable - SD Immutable Cluster Schema

This document explains the full schema for the `kind: Immutable` for the `furyctl.yaml` file used by `furyctl`. This configuration file will be used to deploy the SIGHUP Distribution on Flatcar Container Linux using Matchbox-based provisioning.

An example configuration file can be created by running the following command:

```bash
furyctl create config --kind Immutable --version v1.33.1 --name example-cluster
```

> [!NOTE]
> Replace the version with your desired version of KFD.
