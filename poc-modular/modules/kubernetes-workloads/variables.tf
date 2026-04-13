variable "name_prefix" {
  description = "Kaynak isimlerinde kullanılacak önek"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace adı (boş bırakılırsa name_prefix-ns kullanılır)"
  type        = string
  default     = ""
}

variable "replicas" {
  description = "Deployment replica sayısı"
  type        = number
  default     = 2
}

variable "image" {
  description = "Container image"
  type        = string
  default     = "nginx:latest"
}

variable "labels" {
  description = "Tüm kaynaklara uygulanacak etiketler"
  type        = map(string)
  default     = { managed-by = "opentofu" }
}
