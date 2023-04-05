output "pool_name" {
  description = "Pool name"
  value       = module.gh_oidc.pool_name
}

output "provider_name" {
  description = "Provider name"
  value       = module.gh_oidc.provider_name
}

output "sa_email" {
  description = "SA email"
  value       = google_service_account.devops-challenge_sa.email
}

output "gar_address" {
  description = "Registry address"
  value       = google_artifact_registry_repository.gar_devops-challenge.id
}