terraform {
  required_version = ">= 0.14"

  required_providers {
    # FYI. Cloud Run support was added on 3.3.0
    google = {
      source  = "hashicorp/google"
      version = "4.59.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}