# Store the tf_state in GCS bucket
data "terraform_remote_state" "tf_state" {
  backend = "gcs"
  config = {
    bucket = "tf-state-devops-challenge"
    prefix = "devops-challenge/bootstrap"
  }
}

# Enable the IAM service to be able to create a SA
resource "google_project_service" "project" {
  project = var.gcp_project_id
  service = "iam.googleapis.com"
  timeouts {
    create = "30m"
    update = "40m"
  }
  disable_dependent_services = true
}

# Create a SA
resource "google_service_account" "gar_service_account" {
  account_id   = "gar-sa-devops-challenge"
  display_name = "Service Account to work with Google Artifact Repositories"
}

# Grant permissions to the SA
resource "google_project_iam_member" "gar_repoAdmin_binding" {
  project = var.gcp_project_id
  role    = "roles/artifactregistry.repoAdmin"
  member  = "serviceAccount:${google_service_account.gar_service_account.email}"
}

# Create a Artifact Registry to store our app images. Must be created before hand to build/push images.
resource "google_artifact_registry_repository" "devops-challenge" {
  location      = var.gcp_region
  repository_id = var.project_name
  description   = "Artifact Repository for ${var.project_name}"
  format        = "DOCKER"
}