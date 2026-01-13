# SD On High-Density Bare-Metal Nodes

This folder contains configuration files used to run stress tests on a bare-metal environent.

You can read about our findings in the [documentation website](https://docs.sighup.io/reports/bare-metal).

## Setup

Prerequisites:

- Install [mise-en-place](https://mise.jdx.dev/)
- Install a compose-compatible runtime (e.g.: Docker)
- Open this folder in a terminal and run `mise trust && mise install`
- Edit the [mise.toml](mise.toml) file to match your environment. You may also want to add other variables (e.g.: `FURYCTL_WORKDIR`)
- Edit the [furyctl.yaml](furyctl.yaml) file to match your environment
- Create the SIGHUP Distribution cluster with `furyctl apply`

To run the stress test:

- Edit the files in [kube-burner/kubelet-density-heavy](./kubelet-density-heavy/) to match your desired stress test and Prometheus ingress name
- Run `docker compose up -d` (or the equivalent for your runtime)
- Run `mise burn`
