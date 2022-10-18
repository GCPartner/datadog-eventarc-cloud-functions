output "secret_manager_project_id" {
  description = "The secret manager project id"
  value       = split("/", google_secret_manager_secret.pnap_client_id.name)[1]
}
