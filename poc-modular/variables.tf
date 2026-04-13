# ─── OpenStack ────────────────────────────────────────────────────────────────
variable "os_auth_url" {
  description = "OpenStack Keystone auth URL"
  type        = string
}

variable "os_username" {
  description = "OpenStack kullanıcı adı"
  type        = string
}

variable "os_password" {
  description = "OpenStack şifresi"
  type        = string
  sensitive   = true
}

variable "os_project_name" {
  description = "OpenStack proje adı"
  type        = string
}

variable "os_project_id" {
  description = "OpenStack proje ID"
  type        = string
}

variable "os_user_domain_name" {
  description = "OpenStack user domain adı"
  type        = string
  default     = "user_domain"
}

variable "os_project_domain_id" {
  description = "OpenStack proje domain ID"
  type        = string
}

variable "os_region" {
  description = "OpenStack bölge"
  type        = string
  default     = "RegionOne"
}

# ─── Proxmox ──────────────────────────────────────────────────────────────────
variable "proxmox_endpoint" {
  description = "Proxmox API endpoint URL"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token (format: user@realm!tokenid=secret)"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Proxmox node adı"
  type        = string
  default     = "proxmox-01"
}

variable "proxmox_insecure" {
  description = "TLS doğrulamasını atla (self-signed sertifika)"
  type        = bool
  default     = true
}

# ─── Genel ────────────────────────────────────────────────────────────────────
variable "vm_name_prefix" {
  description = "Tüm kaynak isimlerinde kullanılacak önek"
  type        = string
  default     = "iac-demo"
}

variable "vm_count" {
  description = "Proxmox'ta oluşturulacak VM sayısı"
  type        = number
  default     = 2
}
