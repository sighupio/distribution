# on-premises install e2e (single VM + vabbe)

Provisions **one** throwaway Hetzner VM with Docker and runs the whole on-premises
cluster *inside it*: the Kubernetes nodes are Docker containers acting like VMs
(systemd + sshd, static IPs), brought up by [`vabbe`](https://github.com/nutellinoit/vabbe).
One VM instead of nine — no private network, no per-node provisioning, no nested
virtualization. Driven from CI by the `e2e-onpremises` pipeline in `.drone.yml`.

## Flow
1. `0.local-tofu-run.yaml` — `tofu apply` → 1 VM (Docker via cloud-init); writes `hosts.yaml` with its IP.
2. `1.remote-e2e.yaml` — on the VM: install mise, clone the distribution at the tested commit, run `bootstrap.sh`, then `run-kube-bench.sh` and the bats suite. (The API/ingress are on container IPs reachable only from the VM, so install **and** tests run there.)
3. `2.local-tofu-destroy.yaml` — `tofu destroy` (always).

`bootstrap.sh`: `mise install` → `vabbe keygen` → `vabbe host-prep --run` (swap off + kernel modules) → `vabbe up --wait` → `furyctl apply` (driven from the in-network runner).

## Layout
```
onpremises/
  0.local-tofu-run.yaml        ansible playbooks (orchestration) — run from here
  1.remote-e2e.yaml
  2.local-tofu-destroy.yaml
  ansible.cfg  hosts.yaml
  terraform/   the single-VM infra (main, variables, access, firewall, vm, output).tf
  scripts/     bootstrap.sh, run-kube-bench.sh, create_ingress_certs.sh
  config/      cluster payload: vabbe.yaml, furyctl.yaml, mise.toml, encrypted-secret-config.yaml,
               req-dns.cnf, haproxy-additional.cfg  (also where pki/, tls.*, kubeconfig get generated)
  tests/       bats: e2e-onpremises.sh, helper.bash, schema.sh
```
`bootstrap.sh` operates from `config/` so vabbe's and furyctl's relative paths
(mounts, `{file://./...}`, `pki/`, `tls.*`, `kubeconfig`) all resolve there.

## Why this config differs from bare-metal
- `advanced.kubeProxy.type: none` → Cilium kube-proxy-replacement. kube-proxy can't
  write the init-netns `nf_conntrack_max` sysctl from a container netns.
- single haproxy, no VIP (keepalived disabled; its fields are kept as unused dummies
  because the template renders them unconditionally).
- distribution runs on the 3 workers (`common.nodeSelector: role: worker`).
- the vabbe node image handles `/` rshared (CNI mount propagation) and a
  pod-reachable resolv.conf (CoreDNS would otherwise loop on Docker's `127.0.0.11`).

## Storage
Uses **local-path-provisioner** (kustomize plugin in `config/plugins/`) as the
default StorageClass — node-local dirs, container-friendly. longhorn (the usual
on-prem storage) is intentionally not used here: it needs open-iscsi/iscsid on the
nodes, which is hostile inside container-nodes.
