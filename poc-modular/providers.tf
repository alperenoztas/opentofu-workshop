provider "openstack" {
  auth_url          = var.os_auth_url
  user_name         = var.os_username
  password          = var.os_password
  tenant_name       = var.os_project_name
  tenant_id         = var.os_project_id
  user_domain_name  = var.os_user_domain_name
  project_domain_id = var.os_project_domain_id
  region            = var.os_region
  insecure          = true
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = var.proxmox_insecure
}
