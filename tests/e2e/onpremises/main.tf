# Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
# Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.45"
    }
  }
  backend "s3" {
    bucket = "tf-state-e2e-fury-ci"
    key    = "hetzner/e2e-${var.ci_number}"
    region = "eu-west-1"
  }
}

provider "hcloud" {
  token = var.hcloud_token
}