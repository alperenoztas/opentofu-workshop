# ─── Data Sources ─────────────────────────────────────────────────────────────
data "openstack_networking_network_v2" "external" {
  name = var.external_network_name
}

data "openstack_images_image_v2" "vm_image" {
  name        = var.image_name
  most_recent = true
}

data "openstack_compute_flavor_v2" "vm_flavor" {
  name = var.flavor_name
}

# ─── Network ──────────────────────────────────────────────────────────────────
resource "openstack_networking_network_v2" "network" {
  name           = "${var.name_prefix}-network"
  admin_state_up = true
}

resource "openstack_networking_subnet_v2" "subnet" {
  name            = "${var.name_prefix}-subnet"
  network_id      = openstack_networking_network_v2.network.id
  cidr            = var.subnet_cidr
  ip_version      = 4
  dns_nameservers = var.dns_nameservers
}

resource "openstack_networking_router_v2" "router" {
  name                = "${var.name_prefix}-router"
  admin_state_up      = true
  external_network_id = data.openstack_networking_network_v2.external.id
}

resource "openstack_networking_router_interface_v2" "router_iface" {
  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.subnet.id
}

# ─── Security Group ───────────────────────────────────────────────────────────
resource "openstack_networking_secgroup_v2" "sg" {
  name        = "${var.name_prefix}-sg"
  description = "${var.name_prefix} - OpenTofu ile yönetilmektedir"
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

# ─── VM Port (floating IP association için explicit port) ─────────────────────
resource "openstack_networking_port_v2" "vm_port" {
  name               = "${var.name_prefix}-port"
  network_id         = openstack_networking_network_v2.network.id
  admin_state_up     = true
  security_group_ids = [openstack_networking_secgroup_v2.sg.id]

  fixed_ip {
    subnet_id = openstack_networking_subnet_v2.subnet.id
  }
}

# ─── Compute Instance ─────────────────────────────────────────────────────────
resource "openstack_compute_instance_v2" "vm" {
  name      = "${var.name_prefix}-vm"
  image_id  = data.openstack_images_image_v2.vm_image.id
  flavor_id = data.openstack_compute_flavor_v2.vm_flavor.id
  key_pair  = var.key_pair
  metadata  = var.vm_metadata

  network {
    port = openstack_networking_port_v2.vm_port.id
  }
}

# ─── Floating IP ──────────────────────────────────────────────────────────────
resource "openstack_networking_floatingip_v2" "fip" {
  pool = var.external_network_name
}

resource "openstack_networking_floatingip_associate_v2" "fip_assoc" {
  floating_ip = openstack_networking_floatingip_v2.fip.address
  port_id     = openstack_networking_port_v2.vm_port.id
}
