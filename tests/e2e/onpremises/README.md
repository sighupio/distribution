# on-premises install e2e (libvirt VMs)

Provisions a throwaway HA cluster of **real KVM VMs** on the Drone worker via
[terraform-libvirt](https://github.com/dmacvicar/terraform-provider-libvirt) and
installs the full SIGHUP distribution on it with `furyctl`. Replaces the previous
Hetzner cloud VMs: same topology, but local to the worker — no cloud account, no
remote state, and (being real VMs with a full kernel) cilium / longhorn /
kube-bench behave exactly as on a bare-metal on-prem cluster.

Driven from CI by the `e2e-onpremises` pipeline in `.drone.yml`. Requires a worker
with `/dev/kvm` + libvirt — set up by the infra `libvirt` ansible role.

## Topology
Mirrors the production HA layout, on a per-run `/24` (`10.10.<octet>.0/24`, where
`<octet>` is derived from the build number so concurrent runs don't collide):

| role | host | IP |
|------|------|----|
| haproxy (LB) | haproxy | `.2` |
| control plane | controlplane-0/1/2 | `.3` `.4` `.5` |
| infra | infra-0/1/2 | `.6` `.7` `.8` |
| worker | worker-0/1 | `.9` `.10` |

## CI flow (`.drone.yml`)
1. **install-tools** — `mise install` (opentofu, furyctl, kubectl, ansible).
2. **provision-vms** — install `genisoimage`/`libvirt-clients`/`qemu-utils`;
   `wait-for-free-worker.sh` (block until no other e2e VMs are running); cache the
   Ubuntu 24.04 base image; `tofu apply` (9 VMs); render `config/furyctl.yaml`,
   `req-dns.cnf`, `haproxy-additional.cfg` from `tofu output`; generate ingress certs.
3. **install** — `install.sh`: `furyctl create pki` → `furyctl apply` (retried) →
   a second `furyctl apply --phase distribution` once the longhorn StorageClass
   exists, so the storage-backed stateful components (minio/velero/loki/tempo) land.
4. **bats-test-distribution** — bats distribution checks (`tests/e2e-onpremises.sh`), bounded at 60m.
5. **kube-bench** — `kube-bench.sh`: CIS benchmark on controlplane-0 + worker-0.
6. **delete** — `tofu destroy` (always, on success or failure).

furyctl runs **in the CI runner** (`network_mode: host`) and reaches the VMs over
the worker's libvirt bridge; it SSHes into each node itself, so no separate
orchestration playbooks are needed.

## Layout
```
onpremises/
  terraform/    libvirt infra: main.tf (9 VMs, per-run net), variables.tf,
                output.tf (renders furyctl.yaml / req-dns.cnf / haproxy-additional.cfg)
  scripts/      install.sh (furyctl double-apply), kube-bench.sh, create_ingress_certs.sh,
                wait-for-free-worker.sh (serialization gate)
  playbooks/    kube-bench.yaml (CIS benchmark on controlplane-0 + worker-0, SIGHUP config)
  config/       encrypted-secret-config.yaml (committed); furyctl.yaml, req-dns.cnf,
                haproxy-additional.cfg, kubeconfig, pki/, tls.* are generated here
  tests/        bats: e2e-onpremises.sh, helper.bash, schema.sh
```

## Notes
- **Storage**: longhorn (the usual on-prem storage) — works because these are real
  VMs with iSCSI, unlike container-based nodes. The install step applies twice so
  storage-backed components come up once the StorageClass exists.
- **Concurrency**: each run gets its own libvirt network + `/24` + pool, keyed on
  `ci_number`. `wait-for-free-worker.sh` blocks a run until no other e2e VMs are
  running (the worker fits roughly one full run at a time); install and upgrade
  runs serialize on the same gate.
- **Base image**: cached on the worker at `/root/libvirt_base/noble-20g.img`,
  downloaded once; VMs are full copies of it (no CoW backing — see the comment in
  `main.tf` re: AppArmor / virt-aa-helper on the worker).
