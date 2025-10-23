variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# GKE Node Service Account
resource "google_service_account" "gke_nodes" {
  account_id   = "gke-nodes-${var.environment}"
  display_name = "GKE Node Service Account (${var.environment})"
  description  = "Service account for GKE cluster nodes"
  project      = var.project_id
}

# Application Service Account
resource "google_service_account" "app_service_account" {
  account_id   = "app-${var.environment}"
  display_name = "Application Service Account (${var.environment})"
  description  = "Service account for application workloads"
  project      = var.project_id
}

# Cloud SQL Proxy Service Account
resource "google_service_account" "cloudsql_proxy" {
  account_id   = "cloudsql-proxy-${var.environment}"
  display_name = "Cloud SQL Proxy Service Account (${var.environment})"
  description  = "Service account for Cloud SQL proxy"
  project      = var.project_id
}

# IAM Permissions for GKE Nodes
resource "google_project_iam_member" "gke_nodes_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_nodes_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_nodes_monitoring_viewer" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_project_iam_member" "gke_nodes_storage_viewer" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

# IAM Permissions for Application
resource "google_project_iam_member" "app_storage_admin" {
  project = var.project_id
  role    = "roles/storage.objectAdmin"
  member  = "serviceAccount:${google_service_account.app_service_account.email}"
}

resource "google_project_iam_member" "app_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.app_service_account.email}"
}

# IAM Permissions for Cloud SQL Proxy
resource "google_project_iam_member" "cloudsql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloudsql_proxy.email}"
}