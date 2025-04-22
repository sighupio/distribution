
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