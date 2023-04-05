# Let's store the Terraform state in a Google Cloud Storage bucket. Must be existing before to run the first plan/apply
terraform {
  backend "gcs" {
    bucket = "tf-state-devops-challenge"
    prefix = "terraform/state"
  }
}