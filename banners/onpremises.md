# OnPremises - SD On Premises Cluster Schema

This document explains the full schema for the `kind: OnPremises` for the `furyctl.yaml` file used by `furyctl`. This configuration file will be used to deploy the SIGHUP Distribution modules and cluster on premises.

An example configuration file can be created by running the following command:

```bash
furyctl create config --kind OnPremises --version v1.29.4 --name example-cluster
```

> [!NOTE]
> Replace the version with your desired version of KFD.
