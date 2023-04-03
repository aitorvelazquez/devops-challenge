# Display the service URL
output "service_url" {
  value = "${google_cloud_run_service.test-app.status[0].url}/health"
}
