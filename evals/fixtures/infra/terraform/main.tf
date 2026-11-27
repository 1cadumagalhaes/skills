terraform {
  required_version = ">= 1.8.0, < 2.0.0"
  backend "gcs" {
    bucket = "demo-platform-tfstate"
    prefix = "analytics/api-gateway"
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}
provider "google" {
  project = "demo-platform"
  region  = "us-central1"
}
resource "google_container_cluster" "analytics" {
  name = "analytics-autopilot"
  location = "us-central1"
  enable_autopilot = true
  deletion_protection = true
  workload_identity_config { workload_pool = "demo-platform.svc.id.goog" }
  release_channel { channel = "REGULAR" }
}
resource "google_service_account" "ingest_worker" {
  account_id   = "api-gateway"
  display_name = "Ingest worker workload identity"
}
resource "google_service_account" "terraform_deployer" {
  account_id   = "terraform-deployer"
  display_name = "GitHub Actions Terraform deployer"
}
