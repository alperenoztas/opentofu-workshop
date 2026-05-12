variable "name_prefix" {
  description = "Kaynak isimlerinde kullanılacak önek"
  type        = string
}

variable "external_network_name" {
  description = "Dış ağ (ext_net) adı"
  type        = string
  default     = "ext_net"
}

variable "subnet_cidr" {
  description = "Oluşturulacak subnet CIDR bloğu"
  type        = string
  default     = "192.168.100.0/24"
}

variable "dns_nameservers" {
  description = "DNS sunucuları"
  type        = list(string)
  default     = ["8.8.8.8", "8.8.4.4"]
}

variable "image_name" {
  description = "VM için kullanılacak image adı"
  type        = string
  default     = "ULAKBIM-Ubuntu-22.04-jammy"
}

variable "flavor_name" {
  description = "VM için kullanılacak flavor adı"
  type        = string
  default     = "fkm.c2m4.d20"
}

variable "key_pair" {
  description = "OpenStack key pair adı"
  type        = string
  default     = "alperen-macbook"
}

variable "vm_metadata" {
  description = "VM için metadata etiketleri"
  type        = map(string)
  default = {
    managed_by = "opentofu"
  }
}
