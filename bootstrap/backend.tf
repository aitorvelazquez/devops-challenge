terraform {
  backend "gcs" {
    bucket = "tf-state-devops-challenge"
    prefix = "devops-challenge/bootstrap"
  }
}