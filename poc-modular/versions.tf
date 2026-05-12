terraform {
  required_version = ">= 1.8.0"

  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 2.1"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.70"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
  }
}
