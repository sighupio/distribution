# EKSCluster - EKS Cluster Schema

This document explains the full schema for the `kind: EKSCluster` for the `furyctl.yaml` file used by `furyctl`. This configuration file will be used to deploy a SIGHUP Distribution cluster deployed through AWS's Elastic Kubernetes Service.

An example configuration file can be created by running the following command:

```bash
furyctl create config --kind EKSCluster --version v1.29.4 --name example-cluster
```

> [!NOTE]
> Replace the version with your desired version of KFD.
