resource "proxmox_virtual_environment_vm" "vm" {
  count     = var.vm_count
  name      = "${var.name_prefix}-${count.index + 1}"
  node_name = var.node_name
  started   = var.started

  description = "OpenTofu ile otomatik oluşturuldu - ULAKFKM IaC"
  tags        = var.tags

  cpu {
    cores = var.cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.memory_mb
  }

  disk {
    datastore_id = var.datastore_id
    file_format  = "qcow2"
    interface    = "virtio0"
    size         = var.disk_size_gb
  }

  network_device {
    bridge = var.bridge
    model  = "virtio"
  }

  initialization {
    datastore_id = var.datastore_id
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
    user_account {
      username = "ubuntu"
      keys     = []
    }
  }

  agent {
    enabled = false
  }

  operating_system {
    type = "l26"
  }
}
