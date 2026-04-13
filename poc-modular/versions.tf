terraform {
  required_version = ">= 1.8.0"

  # Remote state — MinIO backend (Lab 5)
  # Aktifleştirmek için yorumları kaldırın ve tofu init -reconfigure çalıştırın
  #
  # backend "s3" {
  #   bucket                      = "opentofu-state"
  #   key                         = "ulakfkm/iac-workshop/terraform.tfstate"
  #   region                      = "us-east-1"
  #   endpoint                    = "https://minio.ulakbim.gov.tr"
  #   access_key                  = "minioadmin"
  #   secret_key                  = "minioadmin"
  #   skip_credentials_validation = true
  #   skip_metadata_api_check     = true
  #   skip_region_validation      = true
  #   force_path_style            = true
  # }

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
