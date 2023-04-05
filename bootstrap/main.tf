# Store the tf_state in GCS bucket
data "terraform_remote_state" "tf_state" {
  backend = "gcs"
  config = {
    bucket = "tf-state-devops-challenge"
    prefix = "devops-challenge/bootstrap"
  }
}

# Create a Artifact Registry to store our app image
resource "google_artifact_registry_repository" "devops-challenge" {
  location      = var.gcp_region
  repository_id = var.project_name
  description   = "Artifact Repository for ${var.project_name}"
  format        = "DOCKER"
}