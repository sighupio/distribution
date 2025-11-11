#!/bin/bash
# Quick generator for Immutable provider configuration

set -e

CLUSTER_NAME="${1:-my-cluster}"
OUTPUT_FILE="${2:-${CLUSTER_NAME}-immutable.yaml}"

echo "Generating Immutable provider configuration..."
echo "  Cluster name: $CLUSTER_NAME"
echo "  Output file: $OUTPUT_FILE"
echo ""

cat > "$OUTPUT_FILE" << YAML
apiVersion: kfd.sighup.io/v1alpha2
kind: Immutable
metadata:
  name: ${CLUSTER_NAME}

spec:
  distributionVersion: v1.33.1

  infrastructure:
    matchbox:
      url: https://matchbox.internal.example.com:8080

    # Physical infrastructure for Matchbox/Ignition provisioning
    nodes:
      controlPlanes:
        - hostname: master1.${CLUSTER_NAME}.example.com
          macAddress: "52:54:00:aa:bb:10"
          installDisk: /dev/sda
          networkInterfaces:
            - name: ens3
              dhcp: false
              addresses: ["10.0.1.20/24"]
              gateway: 10.0.1.1
              dns: ["10.0.1.53"]

      workers:
        - hostname: worker1.${CLUSTER_NAME}.example.com
          macAddress: "52:54:00:aa:bb:20"
          installDisk: /dev/sda
          networkInterfaces:
            - name: ens3
              dhcp: false
              addresses: ["10.0.1.30/24"]
              gateway: 10.0.1.1
              dns: ["10.0.1.53"]

    ssh:
      keyPath: ~/.ssh/id_ed25519

  kubernetes:
    controlPlaneAddress: k8s-api.${CLUSTER_NAME}.example.com
    controlPlanePort: 6443

    controlPlanes:
      - hostname: master1.${CLUSTER_NAME}.example.com
        ip: 10.0.1.20

    workers:
      - hostname: worker1.${CLUSTER_NAME}.example.com
        ip: 10.0.1.30

  distribution:
    common:
      registry: registry.sighup.io/fury
    modules:
      networking:
        type: calico
      ingress:
        baseDomain: ${CLUSTER_NAME}.example.com
        nginx:
          type: single
        certManager:
          clusterIssuer:
            name: letsencrypt-prod
            email: admin@example.com
            type: http01
      monitoring:
        type: prometheus
      logging:
        type: loki
YAML

echo "✓ Configuration file created: $OUTPUT_FILE"
echo ""
echo "Validating against schema..."
if jv schemas/public/immutable-kfd-v1alpha2.json "$OUTPUT_FILE" > /dev/null 2>&1; then
    echo "✓ Configuration is valid!"
else
    echo "✗ Configuration validation failed:"
    jv schemas/public/immutable-kfd-v1alpha2.json "$OUTPUT_FILE"
    exit 1
fi

echo ""
echo "Next steps:"
echo "  1. Edit $OUTPUT_FILE with your actual node details"
echo "  2. Run: furyctl generate pki -c $OUTPUT_FILE"
echo "  3. Run: furyctl dump -c $OUTPUT_FILE --outdir \$PWD"
echo "  4. Run: furyctl apply -c $OUTPUT_FILE --outdir \$PWD"
