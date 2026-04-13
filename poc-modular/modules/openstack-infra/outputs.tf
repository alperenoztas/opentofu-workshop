output "network_id" {
  description = "Oluşturulan network ID"
  value       = openstack_networking_network_v2.network.id
}

output "subnet_cidr" {
  description = "Subnet CIDR bloğu"
  value       = openstack_networking_subnet_v2.subnet.cidr
}

output "security_group_name" {
  description = "Security group adı"
  value       = openstack_networking_secgroup_v2.sg.name
}

output "vm_id" {
  description = "VM ID"
  value       = openstack_compute_instance_v2.vm.id
}

output "vm_name" {
  description = "VM adı"
  value       = openstack_compute_instance_v2.vm.name
}

output "floating_ip" {
  description = "Atanan floating IP adresi"
  value       = openstack_networking_floatingip_v2.fip.address
}
