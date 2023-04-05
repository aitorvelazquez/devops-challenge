# Store the tf_state in GCS bucket
data "terraform_remote_state" "tf_state" {
  backend = "gcs"
  config = {
    bucket = "tf-state-devops-challenge"
    prefix = "devops-challenge/bootstrap"
  }
}

# Create a Artifact Registry to store our app images. Must be created before hand to build/push images.
resource "google_artifact_registry_repository" "gar_devops-challenge" {
  location      = var.gcp_region
  repository_id = var.project_name
  description   = "Artifact Repository for ${var.project_name}"
  format        = "DOCKER"
}

resource "google_project_service" "iam_api" {
  project = var.gcp_project_id
  service = "iam.googleapis.com"
  timeouts {
    create = "30m"
    update = "40m"
  }
  disable_dependent_services = true
}

resource "google_service_account" "devops-challenge_sa" {
  account_id   = "devops-challenge-sa"
  display_name = "Service Account for DevOps-Challenge project"
}

resource "google_project_iam_member" "sa_role_binding" {
  project = var.gcp_project_id
  role    = "roles/artifactregistry.admin"
  member  = "serviceAccount:${google_service_account.devops-challenge_sa.email}"
}

# Create a Workload Identity pool, configure a Workload Identity provider and Granting external identities necessary IAM roles on Service Accounts
# Required to authenticate to GCP using GitHub Actions OIDC tokens
module "gh_oidc" {
  source      = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  project_id  = var.gcp_project_id
  pool_id     = "my-pool"
  provider_id = "devops-challenge-gh-provider"
  sa_mapping = {
    (google_service_account.devops-challenge_sa.account_id) = {
      sa_name   = google_service_account.devops-challenge_sa.name
      attribute = "attribute.repository/${var.gh_user_repo}"
    }
  }
}
