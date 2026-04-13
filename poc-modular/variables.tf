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

# ─── Genel ────────────────────────────────────────────────────────────────────
variable "vm_name_prefix" {
  description = "Tüm kaynak isimlerinde kullanılacak önek"
  type        = string
  default     = "iac-demo"
}
