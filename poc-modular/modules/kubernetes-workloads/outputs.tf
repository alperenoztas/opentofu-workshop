output "namespace" {
  description = "Oluşturulan namespace adı"
  value       = kubernetes_namespace_v1.this.metadata[0].name
}

output "deployment_name" {
  description = "Deployment adı"
  value       = kubernetes_deployment_v1.app.metadata[0].name
}

output "service_name" {
  description = "Service adı"
  value       = kubernetes_service_v1.app.metadata[0].name
}
