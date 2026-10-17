# Immutable install e2e

This e2e creates a temporary HA cluster of Flatcar KVM VMs with
[terraform-libvirt](https://github.com/dmacvicar/terraform-provider-libvirt).
Then it installs the full distribution with `furyctl` and runs the distribution
checks and the CIS kube-bench benchmark.

The VMs start with empty disks. They boot from the network, the same as bare metal:

1. libvirt's dnsmasq gives each MAC address a fixed IP and the boot file
   `http://<gateway>:8080/boot.ipxe`.
2. furyctl serves the iPXE files, the Flatcar image and the ignition of each node
   on the network gateway.
3. Each VM installs Flatcar to its disk, reboots from the disk and reports `booted`.

CI runs this e2e in the `e2e-immutable` pipeline in `.drone.yml`. The pipeline
starts on `e2e-immutable-*` and `e2e-all-*` tags. It needs a host with `/dev/kvm`
and libvirt.

## Topology

Each run uses its own `/24` (`10.10.<octet>.0/24`). The build number sets the
octet in the range 200..249, so the subnet is different from the on-premises
pipelines.

| role | hosts | IP |
|------|-------|----|
| load balancer (HAProxy + keepalived) | lb-0, lb-1 | `.2` `.3` |
| control plane | controlplane-0/1/2 | `.4` `.5` `.6` |
| infra | infra-0/1/2 | `.7` `.8` `.9` |
| worker | worker-0 | `.10` |
| keepalived VIP (API and ingress) | | `.20` |

The hostname of each node includes its IP, for example
`controlplane-0.10-10-205-4.nip.io`. nip.io resolves these names for the runner
and for the nodes. Immutable uses the hostname for SSH, for the etcd URLs and for
the API address, so every name must resolve.

worker-0 gets its address from DHCP after the install. All other nodes use static
addresses. Thus the e2e tests both network configurations.

## Flow

1. **install-tools**: `mise install`.
2. **provision-vms**: the step waits until no other e2e VMs are on the worker.
   Then `tofu apply` creates the VMs powered off. The step writes `furyctl.yaml`
   from `tofu output` and creates the ingress certificates.
3. **install**: `scripts/install.sh` runs the on-premises install sequence. While
   the first `furyctl apply` serves the iPXE files, `scripts/power-on.sh` starts
   the VMs.
4. **bats-test-distribution**: the on-premises bats suite makes sure that the
   distribution components are running.
5. **kube-bench**: the CIS benchmark on controlplane-0 and worker-0.
6. **delete**: `tofu destroy` (always, on success or failure).

## Layout

```
immutable/
  tofu/       libvirt network (DHCP + boot file), empty disks, VMs; output.tf
              writes furyctl.yaml, furyctl_upgrade.yaml and req-dns.cnf
  scripts/    install.sh, power-on.sh, kube-bench.sh
  longhorn/   kustomize base for spec.distribution.customResources: upstream
              longhorn.yaml with replica 1, over-provisioning and always-allow
              node drain
  config/     generated at run time: furyctl.yaml, pki/, kubeconfig, tls.*
  schema.sh   schema tests (qa pipeline), with helper.bash
```

The pipeline also uses these files from `../onpremises`: `install.sh`,
`bats-test.sh`, `wait-for-free-worker.sh`, `create_ingress_certs.sh`, the bats
suite, the kube-bench playbook and the encryption configuration.

## Notes

- **Boot timeout**: furyctl waits for every node with no time limit. If a node
  does not boot in 30 minutes (`BOOT_TIMEOUT`), `power-on.sh` stops the install.
  It also saves the screen of each VM to `/root/e2e-diag` on the worker.
- **Memory**: the Flatcar PXE image runs from RAM, so every VM has 3 GB or more.
  The full run uses approximately 55 GB of the 62 GB on the worker.
- **Storage**: longhorn (replica 1), from `spec.distribution.customResources`,
  so it installs in the distribution phase. The install still applies the
  distribution phase two times: furyctl skips the storage-backed modules until
  a default StorageClass exists. Flatcar ships `iscsid` disabled, so
  `furyctl.yaml` enables it and loads `iscsi_tcp` on the Kubernetes nodes.
- **Concurrency**: only one e2e runs on the worker at a time. The VM gate also
  counts VMs that are shut off, because this pipeline creates its VMs powered off.
- **Asset cache**: the Flatcar files (approximately 1 GB) stay in
  `/root/e2e-immutable-assets` on the worker. furyctl does not download a file
  again when the full file is already there. The cluster name is fixed
  (`e2e-immutable`), so the path of the assets does not change between runs.
  The upgrade pipeline uses the same cache.

## Upgrade pipeline

The `e2e-immutable-upgrades-1.35.1-1.36.0` pipeline uses the same tofu and
scripts. It runs after `e2e-immutable` and starts on the same tags.

- The pipeline sets `TF_VAR_name_prefix=e2eimmup` and the octet range 250..254,
  so its VMs and network never collide with the install pipeline.
- `TF_VAR_distribution_version` (v1.35.1) is the version in `furyctl.yaml`, and
  `TF_VAR_upgrade_version` (v1.36.0) is the version in `furyctl_upgrade.yaml`.
  The rest of the two files is the same.
- **install-1.35.1** sets `DISTRO_LOCATION` to the v1.35.1 tag on GitHub, so the
  base cluster is the released v1.35.1 and not this checkout.
- **upgrade-1.36.0** runs `../onpremises/scripts/upgrade.sh`: `furyctl apply
  --upgrade` with this checkout. The nodes already run, so furyctl does not serve
  iPXE: it upgrades the nodes over SSH, one at a time, with drain and reboot.
- The on-premises bats suite runs after the install and after the upgrade.
