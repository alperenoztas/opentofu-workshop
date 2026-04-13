variable "vm_count" {
  description = "Oluşturulacak VM sayısı"
  type        = number
  default     = 1
}

variable "name_prefix" {
  description = "VM isim öneki"
  type        = string
}

variable "node_name" {
  description = "Proxmox node adı"
  type        = string
  default     = "proxmox-01"
}

variable "cores" {
  description = "CPU çekirdek sayısı"
  type        = number
  default     = 2
}

variable "memory_mb" {
  description = "RAM miktarı (MB)"
  type        = number
  default     = 2048
}

variable "disk_size_gb" {
  description = "Disk boyutu (GB)"
  type        = number
  default     = 20
}

variable "datastore_id" {
  description = "Proxmox storage adı"
  type        = string
  default     = "local"
}

variable "bridge" {
  description = "Network bridge adı"
  type        = string
  default     = "vmbr0"
}

variable "tags" {
  description = "VM etiketleri"
  type        = list(string)
  default     = ["opentofu", "ulakfkm"]
}

variable "started" {
  description = "VM oluşturulunca başlatılsın mı"
  type        = bool
  default     = false
}
