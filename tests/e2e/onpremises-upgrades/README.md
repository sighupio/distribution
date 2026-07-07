# on-premises upgrade e2e

Installs the distribution at **v1.34.1** on a throwaway HA cluster of KVM VMs, then
upgrades it to **v1.35.0** with `furyctl`, running the distribution checks after
each step. Same local libvirt infra as the [install e2e](../onpremises/README.md);
this one exercises the real upgrade path.

Runs in CI via the `e2e-onpremises-upgrades-1.34.1-1.35.0` pipeline in `.drone.yml`.
It `depends_on` `e2e-onpremises`, so it runs after the install pipeline rather than
idling in the VM gate for the whole install run.

The VMs, network and pool come from the **shared module** `../onpremises/tofu/modules/vms`
and the shell steps reuse `../onpremises/scripts/*` (via `E2E_DIR`). Only the two
furyctl configs and the bats suite live here.

## Differences from the install e2e
- **calico + gatekeeper** (the install e2e uses cilium + kyverno) — a complementary
  upgrade path. Everything else is lightened the same way for the single worker
  (prometheus not mimir, tracing off, one worker, longhorn replica 1 + over-provisioning).
- **Disjoint subnet range**: `10.10.110..199` and resources named `e2eup-<build>`, so
  it never collides with the install pipeline (`e2e-*`, `10.10.10..99`) on the worker.
- **haproxy ingress** is added by the upgrade, so its bats check runs only in the
  post-upgrade phase (gated on `EXPECT_HAPROXY_INGRESS`).

## Flow
1. **install-tools**, **provision-vms**, **prepare-nodes** — as the install e2e, but
   `provision-vms` also renders `furyctl_upgrade.yaml` (the v1.35.0 target config).
2. **install-1.34.1** — `furyctl apply` of the v1.34.1 base config.
3. **bats-test-1.34.1** — distribution checks on the base cluster.
4. **upgrade-1.35.0** — `furyctl apply --upgrade --force upgrades --config furyctl_upgrade.yaml`.
5. **bats-test-1.35.0** — distribution checks after the upgrade (incl. haproxy ingress).
6. **delete** — `tofu destroy` (always, on success or failure).

## Layout
```
onpremises-upgrades/
  tofu/     calls the shared vms module; output.tf renders furyctl.yaml (v1.34.1)
            and furyctl_upgrade.yaml (v1.35.0)
  config/   encrypted-secret-config.yaml; the furyctl configs, certs, kubeconfig,
            pki/ are generated here
  tests/    bats: e2e-onpremises.sh (reused for both phases), helper.bash
```
