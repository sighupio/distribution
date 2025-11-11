# Immutable Provider Schema Tests

This directory contains comprehensive test cases for the Immutable provider JSON Schema validation.

## Test Statistics

- **Total Tests**: 26
- **Valid Configurations (OK)**: 6
- **Invalid Configurations (NO)**: 20

## Test Execution

Run all tests:
```bash
./test-all.sh
```

Validate individual test:
```bash
jv ../../../../schemas/public/immutable-kfd-v1alpha2.json 001-ok.yaml
```

## Valid Configuration Tests (OK Cases)

### 001-ok.yaml
**Configuration**: Full setup with load balancers and VRRP
**Features**:
- HAProxy load balancers with keepalived (VRRP)
- 3 control planes, 3 workers
- Stacked etcd (default)
- Complete VRRP configuration

### 002-ok.yaml
**Configuration**: No load balancers, OS updates enabled
**Features**:
- Direct connection to control plane (no LB)
- Custom OS update server (Nebraska)
- Automatic update strategy
- Custom SSH username and PKI folder

### 003-ok.yaml
**Configuration**: External etcd nodes (dedicated etcd)
**Features**:
- 3 dedicated etcd nodes
- Separate etcd cluster
- Full node configuration with management IPs

### 004-ok.yaml
**Configuration**: Minimal setup
**Features**:
- 1 control plane, 1 worker (minimum viable)
- No load balancers
- No dedicated etcd (stacked)
- Simplest valid configuration

### 005-ok.yaml
**Configuration**: Custom networking and advanced Kubernetes settings
**Features**:
- Custom pod CIDR (192.168.0.0/16)
- Custom service CIDR (10.96.0.0/12)
- Advanced Kubernetes configuration
- API server extra arguments

### 006-ok.yaml
**Configuration**: OS updates customization with PKI folder
**Features**:
- Custom Nebraska server URL
- Automatic updates with cluster update allowance
- Custom PKI folder location
- Non-standard SSH port (2222)

## Invalid Configuration Tests (NO Cases)

### Core Schema Validation

#### 001-no.yaml
**Error**: Missing required field `spec.infrastructure.matchbox`
**Validates**: Required field enforcement

#### 002-no.yaml
**Error**: Missing required field `spec.kubernetes`
**Validates**: Required kubernetes section

#### 007-no.yaml
**Error**: Invalid `apiVersion` pattern
**Value**: `kfd.sighup.io/invalid` (should be `kfd.sighup.io/v1alpha2`)
**Validates**: API version pattern matching

#### 008-no.yaml
**Error**: Invalid `kind` value
**Value**: `ImmutableOS` (should be `Immutable`)
**Validates**: Kind enum constraint

#### 009-no.yaml
**Error**: Metadata name exceeds maximum length
**Value**: 102 characters (max: 56)
**Validates**: String length constraints

#### 020-no.yaml
**Error**: Empty `distributionVersion`
**Validates**: MinLength constraint enforcement

### Network Configuration Validation

#### 003-no.yaml
**Error**: Invalid hostname (not FQDN)
**Value**: `master1` (should be `master1.example.com`)
**Validates**: FQDN pattern for hostnames

#### 010-no.yaml
**Error**: Invalid MAC address format
**Value**: `52:54:00:ZZ:bb:10` (contains non-hex characters)
**Validates**: MAC address hex pattern

#### 011-no.yaml
**Error**: Invalid IP address format
**Value**: `10.0.1.abc` (contains letters)
**Validates**: IP address pattern

#### 012-no.yaml
**Error**: Invalid CIDR notation
**Value**: `10.0.1.20` (missing /24 netmask)
**Validates**: CIDR format requirement

#### 013-no.yaml
**Error**: Matchbox URL not using HTTPS
**Value**: `http://matchbox...` (should be `https://`)
**Validates**: HTTPS requirement for matchbox

### VRRP/Load Balancer Validation

#### 004-no.yaml
**Error**: `virtualRouterID` out of range
**Value**: 300 (must be 1-255)
**Validates**: Integer range constraints

#### 005-no.yaml
**Error**: `authPassword` exceeds maximum length
**Value**: 21 characters (max: 8)
**Validates**: MaxLength constraint

#### 006-no.yaml
**Error**: `virtualIP` missing CIDR notation
**Value**: `10.0.1.100` (should be `10.0.1.100/24`)
**Validates**: CIDR format for VIP

### Port and Range Validation

#### 014-no.yaml
**Error**: `controlPlanePort` out of range
**Value**: 99999 (must be 1-65535)
**Validates**: Port number range

#### 019-no.yaml
**Error**: SSH port out of range
**Value**: 0 (must be 1-65535)
**Validates**: Port number minimum value

### Enum Validation

#### 015-no.yaml
**Error**: Invalid `updateStrategy` value
**Value**: `immediate` (must be `manual` or `automatic`)
**Validates**: Enum constraints

### Array Validation (minItems)

#### 016-no.yaml
**Error**: Empty `controlPlanes` array
**Validates**: MinItems constraint (requires at least 1)

#### 017-no.yaml
**Error**: Empty `workers` array
**Validates**: MinItems constraint (requires at least 1)

#### 018-no.yaml
**Error**: Empty `networkInterfaces` array
**Validates**: MinItems constraint (requires at least 1)

## Coverage Summary

### What We Test

✅ **Required Fields**: matchbox, kubernetes, nodes, ssh
✅ **String Patterns**: apiVersion, FQDN, MAC address, IP, CIDR
✅ **String Lengths**: metadata.name (max 56), authPassword (max 8)
✅ **Enum Values**: kind, updateStrategy, partitioning
✅ **Integer Ranges**: ports (1-65535), virtualRouterID (1-255)
✅ **Array Constraints**: minItems for controlPlanes, workers, networkInterfaces
✅ **URL Patterns**: HTTPS requirement for matchbox

### Schema Features Validated

- ✅ Root object structure (apiVersion, kind, metadata, spec)
- ✅ Infrastructure layer (matchbox, nodes, osUpdates, pki, ssh)
- ✅ Kubernetes layer (controlPlaneAddress, loadBalancers, networking)
- ✅ Node roles (controlPlanes, workers, etcds, loadBalancers)
- ✅ Network configuration (static IPs, DHCP, DNS)
- ✅ VRRP high availability settings
- ✅ FQDN validation across all hostname fields

## Test Maintenance

When adding new schema properties:

1. Add at least one OK test showing valid usage
2. Add NO tests for each constraint:
   - Pattern validation
   - Range limits (min/max)
   - Required fields
   - Enum values
   - Array constraints

Run tests after schema changes:
```bash
./test-all.sh
```

All tests must pass before committing schema changes.
