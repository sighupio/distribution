# on-premises install e2e

Provisions a throwaway HA cluster of KVM VMs with
[terraform-libvirt](https://github.com/dmacvicar/terraform-provider-libvirt),
installs the full distribution on it with `furyctl`, and runs the distribution
checks and the CIS kube-bench benchmark. The nodes are real VMs (full kernel), so
cilium, longhorn and kube-bench behave as on a bare-metal on-prem cluster.

Runs in CI via the `e2e-onpremises` pipeline in `.drone.yml`. Needs a host with
`/dev/kvm` and libvirt.

## Topology
HA layout on a per-run `/24` (`10.10.<octet>.0/24`, derived from the build number
so concurrent runs don't collide):

| role | hosts | IP |
|------|-------|----|
| haproxy (LB) | haproxy | `.2` |
| control plane | controlplane-0/1/2 | `.3` `.4` `.5` |
| infra | infra-0/1/2 | `.6` `.7` `.8` |
| worker | worker-0/1 | `.9` `.10` |

## Flow
1. **install-tools** — `mise install` (opentofu, furyctl, kubectl, ansible).
2. **provision-vms** — `tofu apply` brings up the VMs; `furyctl.yaml` and its
   supporting files are rendered from `tofu output`; ingress certs are generated.
3. **install** — `furyctl create pki` then `furyctl apply`, followed by a second
   `furyctl apply --phase distribution` once the longhorn StorageClass exists, so
   the storage-backed components (minio/velero/loki/tempo) come up.
4. **bats-test-distribution** — bats checks that the distribution components are running.
5. **kube-bench** — CIS benchmark on a control-plane and a worker node.
6. **delete** — `tofu destroy` (always, on success or failure).

furyctl runs in the CI runner and reaches the VMs over the libvirt network,
SSHing into each node itself.

## Layout
```
onpremises/
  terraform/    libvirt infra: main.tf (the VMs, per-run network), variables.tf,
                output.tf (renders furyctl.yaml / req-dns.cnf / haproxy-additional.cfg)
  scripts/      install.sh, kube-bench.sh, create_ingress_certs.sh, wait-for-free-worker.sh
  playbooks/    kube-bench.yaml (CIS benchmark on one control-plane + one worker)
  config/       encrypted-secret-config.yaml; furyctl.yaml, req-dns.cnf,
                haproxy-additional.cfg, kubeconfig, pki/, tls.* are generated here
  tests/        bats: e2e-onpremises.sh, helper.bash, schema.sh
```

## Notes
- **Storage**: longhorn. The install applies twice so storage-backed components
  come up once the StorageClass is ready.
- **Concurrency**: each run gets its own libvirt network, subnet and pool, and runs
  serialize so only one is active at a time.
