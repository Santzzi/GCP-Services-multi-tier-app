output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "region" {
  description = "GCP Region"
  value       = var.region
}

output "zone" {
  description = "GCP Zone"
  value       = var.zone
}

output "gke_service_account_email" {
  description = "Email of the GKE service account"
  value       = module.iam.gke_service_account_email
}

output "app_service_account_email" {
  description = "Email of the application service account"
  value       = module.iam.app_service_account_email
}

output "cloudsql_proxy_service_account_email" {
  description = "Email of the Cloud SQL proxy service account"
  value       = module.iam.cloudsql_proxy_service_account_email
}