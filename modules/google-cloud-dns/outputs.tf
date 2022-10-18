output "cloud_dns_sa_key" {
  value       = google_service_account_key.cloud_dns.private_key
  description = "Cloud DNS Service Account JSON Key"
}
