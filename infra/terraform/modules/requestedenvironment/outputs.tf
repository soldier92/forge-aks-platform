output "namespace" {
  value = kubernetes_namespace.team.metadata[0].name
}

output "deployment_name" {
  value = try(kubernetes_deployment_v1.team[0].metadata[0].name, null)
}

output "service_name" {
  value = try(kubernetes_service.team[0].metadata[0].name, null)
}
