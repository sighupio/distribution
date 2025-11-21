# Immutable - Bare Metal Immutable Infrastructure Schema

This document explains the full schema for the `kind: Immutable` for the `furyctl.yaml` file used by `furyctl`. This configuration file will be used to provision and deploy bare metal nodes with iPXE boot, storage partitioning, network configuration, and the SIGHUP Distribution modules for immutable Kubernetes infrastructure.

An example configuration file can be created by running the following command:

```bash
furyctl create config --kind Immutable --version v1.32.1 --name production-cluster
```

> [!NOTE]
> Replace the version with your desired version of KFD.
