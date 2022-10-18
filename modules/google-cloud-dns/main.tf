resource "google_service_account" "cloud_dns" {
  account_id   = format("sa-%s-dns", var.cluster_name)
  display_name = format("Anthos Bare Metal Service Account for %s external-dns", var.cluster_name)
  project      = var.gcp_project_id
}

resource "google_project_iam_member" "cloud_dns" {
  role    = "roles/dns.admin"
  member  = format("serviceAccount:%s", google_service_account.cloud_dns.email)
  project = var.gcp_project_id
}

resource "google_service_account_key" "cloud_dns" {
  service_account_id = google_service_account.cloud_dns.name
}
