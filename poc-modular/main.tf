# ─────────────────────────────────────────────────────────────────────────────
# Lab 2 — Düz (flat) yapı: Tüm OpenStack kaynakları doğrudan main.tf içinde
# ─────────────────────────────────────────────────────────────────────────────

# ─── Data Sources ─────────────────────────────────────────────────────────────
data "openstack_networking_network_v2" "external" {
  name = "ext_net"
}

data "openstack_images_image_v2" "vm_image" {
  name        = "ULAKBIM-Ubuntu-22.04-jammy"
  most_recent = true
}

data "openstack_compute_flavor_v2" "vm_flavor" {
  name = "fkm.c2m4.d20"
}

# ─── Network ──────────────────────────────────────────────────────────────────
resource "openstack_networking_network_v2" "network" {
  name           = "${var.vm_name_prefix}-network"
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "subnet" {
  name            = "${var.vm_name_prefix}-subnet"
  network_id      = openstack_networking_network_v2.network.id
  cidr            = "192.168.100.0/24"
  ip_version      = 4
  dns_nameservers = ["8.8.8.8", "8.8.4.4"]
}

resource "openstack_networking_router_v2" "router" {
  name                = "${var.vm_name_prefix}-router"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external.id
}

resource "openstack_networking_router_interface_v2" "router_iface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.subnet.id
}

# ─── Security Group ───────────────────────────────────────────────────────────
resource "openstack_networking_secgroup_v2" "sg" {
  name        = "${var.vm_name_prefix}-sg"
  description = "${var.vm_name_prefix} - OpenTofu ile yönetilmektedir"
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg.id
}

resource "openstack_networking_secgroup_rule_v2" "icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.sg.id
}

# ─── VM Port ──────────────────────────────────────────────────────────────────
resource "openstack_networking_port_v2" "vm_port" {
  name               = "${var.vm_name_prefix}-port"
  network_id         = openstack_networking_network_v2.network.id
  admin_state_up     = true
  security_group_ids = [openstack_networking_secgroup_v2.sg.id]

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet.id
  }
}

# ─── Compute Instance ─────────────────────────────────────────────────────────
resource "openstack_compute_instance_v2" "vm" {
  name      = "${var.vm_name_prefix}-vm"
  image_id  = data.openstack_images_image_v2.vm_image.id
  flavor_id = data.openstack_compute_flavor_v2.vm_flavor.id

  network {
    port = openstack_networking_port_v2.vm_port.id
  }
}

# ─── Floating IP ──────────────────────────────────────────────────────────────
resource "openstack_networking_floatingip_v2" "fip" {
  pool = "ext_net"
}

resource "openstack_networking_floatingip_associate_v2" "fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.fip.address
  port_id     = openstack_networking_port_v2.vm_port.id
}

# ─── Outputs ──────────────────────────────────────────────────────────────────
output "floating_ip" {
  description = "VM'e atanan floating IP"
  value       = openstack_networking_floatingip_v2.fip.address
}

output "vm_name" {
  description = "Oluşturulan VM adı"
  value       = openstack_compute_instance_v2.vm.name
}

output "subnet_cidr" {
  description = "Oluşturulan subnet CIDR"
  value       = openstack_networking_subnet_v2.subnet.cidr
}
