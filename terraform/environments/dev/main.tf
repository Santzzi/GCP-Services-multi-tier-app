# terraform/environments/dev/main.tf
terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
  backend "gcs" {
    bucket = "gcp-track1-terraform-state"
    prefix = "dev/terraform.tfstate"
  }
}

# Create development project
resource "google_project" "dev_project" {
  name            = "DevOps Portfolio Dev"
  project_id      = "devops-portfolio-dev-${random_id.project_suffix.hex}"
  billing_account = var.billing_account

  labels = {
    environment = "dev"
    project     = "devops-portfolio"
    owner       = "santzzi"
  }
}

resource "random_id" "project_suffix" {
  byte_length = 4
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "sql-component.googleapis.com",
    "sqladmin.googleapis.com",
    "storage-api.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "cloudbuild.googleapis.com"
  ])

  project = google_project.dev_project.project_id
  service = each.value
}