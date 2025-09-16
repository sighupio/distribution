#!/bin/bash
# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

set -e
DISTRIBUTION_VERSION=""
CLUSTER_NAME=""
FURYCTL_YAML=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--distribution-version)
      DISTRIBUTION_VERSION="$2"
      shift 2
      ;;
    -c|--cluster-name)
      CLUSTER_NAME="$2"
      shift 2
      ;;
    -f|--furyctl-yaml)
      FURYCTL_YAML="$2"
      shift 2
      ;;
    -h|--help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  -d, --distribution-version   Specify the distribution version"
      echo "  -c, --cluster-name           Specify the cluster name"
      echo "  -f, --furyctl-yaml           Specify the furyctl YAML file path"
      echo "  -h, --help                   Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use -h or --help for usage information"
      exit 1
      ;;
  esac
done

# Check if all required arguments are provided
if [ -z "$CLUSTER_NAME" ] || [ -z "$FURYCTL_YAML" ]; then
    echo "Error: Missing required arguments"
    echo "Usage: $0 -c <cluster_name> -f <furyctl_yaml>"
    exit 1
fi

if [[ -v $DISTRIBUTION_VERSION ]]; then
  yq -ei ".spec.distributionVersion = \"$DISTRIBUTION_VERSION\"" "$FURYCTL_YAML"
fi
yq -ei ".metadata.name = \"$CLUSTER_NAME\"" "$FURYCTL_YAML"
yq -ei ".spec.toolsConfiguration.terraform.state.s3.keyPrefix = \"$CLUSTER_NAME\"" "$FURYCTL_YAML"
yq -ei ".spec.tags.env = \"$CLUSTER_NAME\"" "$FURYCTL_YAML"
if [[ $(yq '.spec.distribution.modules.dr.velero.eks | has("bucketName")' "$FURYCTL_YAML") == "true" ]]; then
  yq -ei ".spec.distribution.modules.dr.velero.eks.bucketName = \"$CLUSTER_NAME-velero\"" "$FURYCTL_YAML"
fi

if [[ $(yq '.spec.distribution.modules.ingress | has("baseDomain")' "$FURYCTL_YAML") == "true" ]]; then
  yq -ei ".spec.distribution.modules.ingress.baseDomain = \"internal.$CLUSTER_NAME.e2e.ci.sighup.cc\"" "$FURYCTL_YAML"
fi
if [[ $(yq '.spec.distribution.modules.ingress.dns.public | has("name")' "$FURYCTL_YAML") == "true" ]]; then
  yq -ei ".spec.distribution.modules.ingress.dns.public.name = \"$CLUSTER_NAME.e2e.ci.sighup.cc\"" "$FURYCTL_YAML"
fi

if [[ $(yq '.spec.distribution.modules.ingress.dns.private | has("name")' "$FURYCTL_YAML") == "true" ]]; then
  yq -ei ".spec.distribution.modules.ingress.dns.private.name = \"internal.$CLUSTER_NAME.e2e.ci.sighup.cc\"" "$FURYCTL_YAML"
fi

if [[ $(yq '.spec.distribution.modules.auth | has("baseDomain")' "$FURYCTL_YAML") == "true" ]]; then
  yq -ei ".spec.distribution.modules.auth.baseDomain = \"$CLUSTER_NAME.e2e.ci.sighup.cc\"" "$FURYCTL_YAML"
fi


