# Immutable Kubernetes Distribution Installer

## Overview

The Immutable installer provides bare-metal Kubernetes deployment using network boot (iPXE) with Flatcar Container Linux. This installer supports heterogeneous architectures, allowing x86-64 and ARM64 nodes in the same cluster.

## Table of Contents

- [Features](#features)
- [Per-Node Architecture Selection](#per-node-architecture-selection)
- [Architecture Support Matrix](#architecture-support-matrix)
- [Configuration Examples](#configuration-examples)
- [How It Works](#how-it-works)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)
- [References](#references)

## Features

- **Network Boot**: PXE boot using iPXE for bare-metal provisioning
- **Immutable OS**: Flatcar Container Linux with systemd-sysext
- **Multi-Architecture**: Mix x86-64 and ARM64 nodes in the same cluster
- **High Availability**: Built-in support for HA control plane and load balancers
- **GitOps Ready**: Configuration as code with furyctl
- **Selective Downloads**: Only downloads assets for architectures in use

## Per-Node Architecture Selection

### Overview

The immutable distribution supports **heterogeneous cluster architectures**, allowing you to mix x86-64 (Intel/AMD) and ARM64 nodes in the same Kubernetes cluster.

### Key Benefits

1. **Hardware Flexibility**: Use existing x86-64 infrastructure alongside new ARM64 servers
2. **Cost Optimization**: Deploy ARM64 workers for cost-effective compute (up to 40% savings)
3. **Workload Compatibility**: Run specialized workloads on appropriate architecture
4. **Efficient Asset Management**: Automatically downloads only required architecture assets
5. **Gradual Migration**: Migrate from x86-64 to ARM64 incrementally without downtime

### Configuration

Each node can specify its architecture using the `arch` field:

```yaml
spec:
  infrastructure:
    nodes:
      - hostname: node01.example.com
        macAddress: "52:54:00:01:00:01"
        arch: x86-64  # Options: x86-64 (default) | arm64
        storage:
          installDisk: /dev/sda
        network:
          # ... network config ...
```

**Default Behavior**: If `arch` is omitted, defaults to `x86-64`.

**Valid Values**:
- `x86-64`: Intel/AMD 64-bit (amd64)
- `arm64`: ARM 64-bit (aarch64)

### How It Works

#### 1. Architecture Detection

When you run `furyctl apply --phase infrastructure`, the system:

1. Scans all nodes in your configuration
2. Identifies unique architectures in use
3. Logs detected architectures: `Detected architectures in cluster: [x86-64 arm64]`

#### 2. Selective Asset Download

The system downloads only necessary assets for detected architectures:

**Flatcar Artifacts** (per architecture):
- Kernel: `flatcar_production_pxe.vmlinuz`
- Initrd: `flatcar_production_pxe_image.cpio.gz`
- Image: `flatcar_production_image.bin.bz2`

**Sysext Packages** (per architecture):
- `containerd-{version}-{arch}.raw` - Container runtime
- `kubernetes-{version}-{arch}.raw` - kubelet, kubeadm, kubectl
- `etcd-{version}-{arch}.raw` - etcd (control plane only)
- `keepalived-{version}-{arch}.raw` - keepalived (load balancers only)

**Example**: Cluster with 3 x86-64 nodes and 3 arm64 nodes downloads:
- 6 Flatcar artifacts (3 per arch)
- 8 sysext packages (4 packages × 2 architectures)

#### 3. Template Rendering

Each node's Butane template is rendered with architecture-specific URLs:

```yaml
# For x86-64 node:
source: https://ipxe.example.com:8080/assets/extensions/kubernetes-v1.33.6-x86-64.raw

# For arm64 node:
source: https://ipxe.example.com:8080/assets/extensions/kubernetes-v1.33.6-arm64.raw
```

#### 4. Boot Process

During PXE boot:
1. Node boots from network via iPXE
2. Downloads Flatcar kernel/initrd for its architecture
3. Butane config is converted to Ignition
4. Flatcar boots and downloads architecture-specific sysext packages
5. systemd-sysext activates extensions (Kubernetes, containerd, etc.)
6. Node joins cluster with correct `kubernetes.io/arch` label

## Architecture Support Matrix

| Component | x86-64 | ARM64 | Notes |
|-----------|:------:|:-----:|-------|
| **Flatcar Container Linux** | ✅ | ✅ | All stable channel versions |
| **Kubernetes** | ✅ | ✅ | 1.29+ officially supported |
| **containerd** | ✅ | ✅ | Runtime via sysext |
| **etcd** | ✅ | ✅ | Control plane datastore |
| **keepalived** | ✅ | ✅ | Load balancer HA |
| **Calico** | ✅ | ✅ | CNI plugin |
| **Nginx Ingress** | ✅ | ✅ | Ingress controller |
| **Prometheus** | ✅ | ✅ | Monitoring stack |
| **Loki** | ✅ | ✅ | Logging stack |

## Configuration Examples

### Single Architecture (All x86-64)

Simplest configuration - omit `arch` field (defaults to x86-64):

```yaml
nodes:
  - hostname: node01.example.com
    macAddress: "52:54:00:01:00:01"
    # arch field omitted - defaults to x86-64
    storage:
      installDisk: /dev/sda
    network:
      ethernets:
        eth0:
          addresses:
            - 192.168.1.10/24
          gateway: 192.168.1.1
          nameservers:
            addresses:
              - 8.8.8.8
              - 8.8.4.4
```

### Single Architecture (All ARM64)

Explicitly set all nodes to arm64:

```yaml
nodes:
  - hostname: node01.example.com
    macAddress: "52:54:00:01:00:01"
    arch: arm64
    storage:
      installDisk: /dev/sda
    network:
      ethernets:
        eth0:
          addresses:
            - 192.168.1.10/24
          gateway: 192.168.1.1
          nameservers:
            addresses:
              - 8.8.8.8
              - 8.8.4.4
```

### Mixed Architecture

For detailed mixed-architecture example, see: [`examples/immutable-mixed-arch-example.yaml`](../../examples/immutable-mixed-arch-example.yaml)

**Recommended architecture distribution**:

| Node Role | Recommended Arch | Rationale |
|-----------|------------------|-----------|
| **Control Plane** | x86-64 | Stability, mature tooling |
| **Load Balancers** | x86-64 | Lightweight, proven |
| **Infra Workers** | arm64 | Cost-effective for system workloads |
| **App Workers** | arm64 or mixed | Price/performance optimization |

## Best Practices

### 1. Container Images

**Requirement**: All workloads must use multi-architecture container images.

**Check image platforms**:
```bash
docker manifest inspect <image> | jq '.manifests[].platform'
```

**Build multi-arch images**:
```bash
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t myapp:latest \
  --push .
```

**Most official images support multi-arch**: nginx, redis, postgres, mysql, etc.

### 2. Node Scheduling

Kubernetes automatically labels nodes with `kubernetes.io/arch`.

**For architecture-specific workloads**, use nodeSelector:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: x86-only-app
spec:
  template:
    spec:
      nodeSelector:
        kubernetes.io/arch: amd64  # Force x86-64
      containers:
        - name: app
          image: myapp:latest
```

**For flexible scheduling with preferences**, use nodeAffinity:

```yaml
spec:
  template:
    spec:
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              preference:
                matchExpressions:
                  - key: kubernetes.io/arch
                    operator: In
                    values:
                      - arm64  # Prefer ARM64
      containers:
        - name: app
          image: myapp:latest
```

### 3. Migration Strategy

**Gradual migration from x86-64 to ARM64**:

1. **Phase 1**: Start with mixed cluster (control plane x86-64, some workers arm64)
2. **Phase 2**: Migrate stateless workloads to ARM64 workers
3. **Phase 3**: Migrate stateful workloads after validation
4. **Phase 4**: Eventually migrate control plane if desired

### 4. Performance Testing

Before production:

1. **Benchmark critical workloads** on both architectures
2. **Test database performance** (PostgreSQL, MySQL, etc.)
3. **Validate compilation times** if building code in-cluster
4. **Monitor memory usage** (ARM64 may behave differently)

### 5. Asset Management

**furyctl automatically manages assets**:
- Downloads only required architectures
- Caches downloads in local directory
- Serves from iPXE server to nodes

**Storage requirements** (per architecture):
- Flatcar artifacts: ~5 GB (kernel + initrd + image)
- Sysext packages: ~150 MB (containerd + kubernetes + etcd + keepalived)

## Troubleshooting

### Issue: Node boots but sysext packages fail to load

**Symptom**: Node boots but Kubernetes components don't start.

**Diagnosis**:
```bash
# SSH to node
ssh core@node01.example.com

# Check sysext status
systemd-sysextd status

# Check available extensions
ls -la /opt/extensions/
```

**Solution**: Verify correct architecture in node config matches hardware.

### Issue: Download exhausted error

**Symptom**: `furyctl apply` fails with "downloading options exhausted".

**Diagnosis**: Check if architecture-specific URLs exist in `immutable.yaml`.

**Solution**:
1. Verify immutable.yaml has URLs for your architectures
2. Check network connectivity to asset URLs
3. Use `file://` URLs for local testing

### Issue: Mixed architecture but pods stuck pending

**Symptom**: Some pods don't schedule in mixed cluster.

**Diagnosis**:
```bash
kubectl describe pod <pod-name>
# Look for: "0/X nodes are available: X node(s) didn't match Pod's node affinity/selector"
```

**Solution**:
1. Check if image supports required architecture
2. Remove unnecessary nodeSelectors
3. Use multi-arch images

### Issue: Cluster performance varies by node

**Symptom**: Workloads run slower on ARM64 nodes.

**Diagnosis**: Architecture-specific performance characteristics.

**Solution**:
1. Benchmark your specific workload
2. Adjust resource requests/limits
3. Use nodeAffinity to route to optimal architecture

### Issue: Schema validation error with arch field

**Symptom**: Error like `arch must be one of: x86-64, arm64`

**Diagnosis**: Invalid architecture value provided.

**Solution**:
- Use `x86-64` (not `amd64` or `x86_64`)
- Use `arm64` (not `aarch64` or `arm`)
- Check for typos in architecture field

## References

- [Flatcar Container Linux Documentation](https://www.flatcar.org/docs/)
- [Kubernetes Multi-Platform Clusters](https://kubernetes.io/docs/concepts/cluster-administration/multi-platform/)
- [systemd-sysext](https://www.freedesktop.org/software/systemd/man/systemd-sysext.html)
- [Butane Configuration Specification](https://coreos.github.io/butane/)
- [Docker Buildx Multi-Platform Builds](https://docs.docker.com/build/building/multi-platform/)

## Examples

- **Basic configuration**: [`templates/config/immutable-kfd-v1alpha2.yaml.tpl`](../../templates/config/immutable-kfd-v1alpha2.yaml.tpl)
- **Advanced features**: [`examples/immutable-full-example.yaml`](../../examples/immutable-full-example.yaml)
- **Mixed architecture**: [`examples/immutable-mixed-arch-example.yaml`](../../examples/immutable-mixed-arch-example.yaml)

## Support

For issues and questions:
- GitHub Issues: https://github.com/sighupio/fury-distribution/issues
- Documentation: https://docs.kubernetesfury.com
