# output "service_url" {
#   value = google_cloud_run_service.adk_service.status[0].url
# }

output "service_account_email" {
  value = google_service_account.adk_sa.email
}

output "artifact_repo" {
  value = google_artifact_registry_repository.repo.repository_id
}
