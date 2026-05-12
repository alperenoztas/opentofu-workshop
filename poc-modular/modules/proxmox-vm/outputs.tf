output "vm_ids" {
  description = "Oluşturulan VM ID listesi"
  value       = proxmox_virtual_environment_vm.vm[*].vm_id
}

output "vm_names" {
  description = "Oluşturulan VM isim listesi"
  value       = proxmox_virtual_environment_vm.vm[*].name
}

output "vm_count" {
  description = "Oluşturulan VM sayısı"
  value       = var.vm_count
}
