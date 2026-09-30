output "cloud_provider_selected" {
  description = "Proveedor de nube seleccionado para el despliegue"
  value       = var.cloud_provider
}

# --- AWS (MSK) Outputs ---
output "aws_vpc_id" {
  description = "ID de la VPC de AWS MSK"
  value       = length(aws_vpc.kafka_vpc) > 0 ? aws_vpc.kafka_vpc[0].id : null
}

# --- GCP (GKE) Outputs ---
output "gcp_vpc_name" {
  description = "Nombre de la red VPC en GCP"
  value       = length(google_compute_network.vpc) > 0 ? google_compute_network.vpc[0].name : null
}

output "gke_cluster_endpoint" {
  description = "Endpoint del clúster GKE"
  value       = length(google_container_cluster.primary) > 0 ? google_container_cluster.primary[0].endpoint : null
}

# --- Confluent Cloud Outputs ---
output "confluent_environment_id" {
  description = "ID del entorno de Confluent Cloud"
  value       = length(confluent_environment.production) > 0 ? confluent_environment.production[0].id : null
}

# --- AWS (EKS) Outputs ---
output "eks_vpc_id" {
  description = "ID de la VPC para AWS EKS"
  value       = length(aws_vpc.eks_vpc) > 0 ? aws_vpc.eks_vpc[0].id : null
}

output "eks_cluster_endpoint" {
  description = "Endpoint del clúster EKS"
  value       = length(aws_eks_cluster.primary) > 0 ? aws_eks_cluster.primary[0].endpoint : null
}