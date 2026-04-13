# ─────────────────────────────────────────────────────────────────────────────
# Lab 2 — OpenStack kaynakları (düz yapı)
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

# ─────────────────────────────────────────────────────────────────────────────
# Lab 3 — Proxmox: count meta-argümanı ile çoklu VM
# ─────────────────────────────────────────────────────────────────────────────
resource "proxmox_virtual_environment_vm" "vm" {
  count     = var.vm_count
  name      = "${var.vm_name_prefix}-${count.index + 1}"
  node_name = var.proxmox_node
  started   = false

  description = "OpenTofu ile otomatik oluşturuldu — ULAKFKM IaC"
  tags        = ["opentofu", "iac-demo", "ulakfkm"]

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
  }

  disk {
    datastore_id = "local"
    file_format  = "qcow2"
    interface    = "virtio0"
    size         = 20
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  agent {
    enabled = false
  }

  operating_system {
    type = "l26"
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Lab 4 — Kubernetes: Namespace, Deployment ve Service (HCL ile)
# ─────────────────────────────────────────────────────────────────────────────

resource "kubernetes_namespace_v1" "demo" {
  metadata {
    name = "${var.vm_name_prefix}-ns"
    labels = {
      managed-by = "opentofu"
      env        = "demo"
    }
  }
}

resource "kubernetes_deployment_v1" "app" {
  metadata {
    name      = "${var.vm_name_prefix}-app"
    namespace = kubernetes_namespace_v1.demo.metadata[0].name
    labels    = { app = "${var.vm_name_prefix}-app" }
  }

  spec {
    replicas = var.k8s_replicas

    selector {
      match_labels = { app = "${var.vm_name_prefix}-app" }
    }

    template {
      metadata {
        labels = { app = "${var.vm_name_prefix}-app" }
      }

      spec {
        container {
          name  = "app"
          image = "nginx:latest"

          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu    = "250m"
              memory = "128Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "64Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "app" {
  metadata {
    name      = "${var.vm_name_prefix}-svc"
    namespace = kubernetes_namespace_v1.demo.metadata[0].name
  }

  spec {
    selector = { app = "${var.vm_name_prefix}-app" }

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "NodePort"
  }
}

# ─── Outputs ──────────────────────────────────────────────────────────────────
output "floating_ip" {
  description = "VM'e atanan floating IP"
  value       = openstack_networking_floatingip_v2.fip.address
}

output "vm_name" {
  description = "Oluşturulan OpenStack VM adı"
  value       = openstack_compute_instance_v2.vm.name
}

output "subnet_cidr" {
  description = "Oluşturulan subnet CIDR"
  value       = openstack_networking_subnet_v2.subnet.cidr
}

output "proxmox_vm_names" {
  description = "Oluşturulan Proxmox VM isimleri"
  value       = proxmox_virtual_environment_vm.vm[*].name
}

output "proxmox_vm_ids" {
  description = "Proxmox VM ID listesi"
  value       = proxmox_virtual_environment_vm.vm[*].vm_id
}

output "k8s_namespace" {
  description = "Oluşturulan Kubernetes namespace"
  value       = kubernetes_namespace_v1.demo.metadata[0].name
}

output "k8s_service_name" {
  description = "Oluşturulan Kubernetes service adı"
  value       = kubernetes_service_v1.app.metadata[0].name
}
