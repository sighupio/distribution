# KFDDistribution - Distribution Only Cluster Schema

This document explains the full schema for the `kind: KFDDistribution` for the `furyctl.yaml` file used by `furyctl`. This configuration file will be used to deploy the SIGHUP Distribution modules on top of an existing Kubernetes cluster.

An example configuration file can be created by running the following command:

```bash
furyctl create config --kind KFDDistribution --version v1.29.4 --name example-cluster
```

> [!NOTE]
> Replace the version with your desired version of KFD.
