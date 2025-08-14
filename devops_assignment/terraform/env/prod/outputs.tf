output "cluster_name" {
  value = module.gke.name
}

output "ingress_ip" {
  value       = try(kubernetes_ingress_v1.ing.status[0].load_balancer[0].ingress[0].ip, null)
  description = "Public IP of the GCLB created by the Ingress"
}
