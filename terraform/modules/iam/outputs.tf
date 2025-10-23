output "gke_service_account_email" {
  description = "Email of the GKE nodes service account"
  value       = google_service_account.gke_nodes.email
}

output "app_service_account_email" {
  description = "Email of the application service account"
  value       = google_service_account.app_service_account.email
}

output "cloudsql_proxy_service_account_email" {
  description = "Email of the Cloud SQL proxy service account"
  value       = google_service_account.cloudsql_proxy.email
}