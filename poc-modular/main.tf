# ─────────────────────────────────────────────────────────────────────────────
# Lab 5 — Modüler yapı: Tüm kaynaklar modüllere taşındı
# OpenTofu ile ULAKFKM Altyapısında Çok Katmanlı IaC
# ─────────────────────────────────────────────────────────────────────────────

# ─── Katman 1: OpenStack Altyapısı ───────────────────────────────────────────
module "openstack_infra" {
  source = "./modules/openstack-infra"

  name_prefix  = var.vm_name_prefix
  subnet_cidr  = "192.168.100.0/24"
  image_name   = "ULAKBIM-Ubuntu-22.04-jammy"
  flavor_name  = "fkm.c2m4.d20"

  vm_metadata = {
    managed_by  = "opentofu"
    project     = "ulakfkm-iac-poc"
    environment = "demo"
  }
}

# ─── Katman 2: Proxmox VM'leri ────────────────────────────────────────────────
module "proxmox_vms" {
  source = "./modules/proxmox-vm"

  name_prefix  = var.vm_name_prefix
  node_name    = var.proxmox_node
  vm_count     = var.vm_count
  cores        = 2
  memory_mb    = 2048
  disk_size_gb = 20
  datastore_id = "local"
  started      = false

  tags = ["opentofu", "iac-demo", "ulakfkm"]
}

# ─── Katman 3: Kubernetes İş Yükleri ─────────────────────────────────────────
module "k8s_workloads" {
  source = "./modules/kubernetes-workloads"

  name_prefix = var.vm_name_prefix
  replicas    = var.k8s_replicas
  image       = "nginx:latest"

  labels = {
    managed-by  = "opentofu"
    project     = "ulakfkm-iac-poc"
    environment = "demo"
  }
}

# ─── Outputs ──────────────────────────────────────────────────────────────────
output "openstack_floating_ip" {
  description = "OpenStack VM floating IP"
  value       = module.openstack_infra.floating_ip
}

output "openstack_vm_name" {
  description = "OpenStack VM adı"
  value       = module.openstack_infra.vm_name
}

output "openstack_subnet_cidr" {
  description = "OpenStack subnet CIDR"
  value       = module.openstack_infra.subnet_cidr
}

output "proxmox_vm_ids" {
  description = "Proxmox VM ID listesi"
  value       = module.proxmox_vms.vm_ids
}

output "proxmox_vm_names" {
  description = "Proxmox VM isimleri"
  value       = module.proxmox_vms.vm_names
}

output "k8s_namespace" {
  description = "Kubernetes namespace"
  value       = module.k8s_workloads.namespace
}

output "k8s_service_name" {
  description = "Kubernetes service adı"
  value       = module.k8s_workloads.service_name
}
