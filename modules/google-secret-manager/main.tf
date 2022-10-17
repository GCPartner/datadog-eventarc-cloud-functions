resource "google_project_service" "enable_secret_manager_api" {
  project            = var.gcp_project_id
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
  provisioner "local-exec" {
    command = <<EOF
      for i in {1..10}; do
        echo "Sleeping $i seconds to wait for Cloud Functions API to be enabled"
        sleep $i
        if gcloud services list --project="${var.gcp_project_id}" | grep "secretmanager.googleapis.com"; then
          exit 0
        fi
        echo "Service not enabled yet..."
      done
      echo "Service was not enabled after 15s"
      exit 1
    EOF
  }
}

resource "google_secret_manager_secret" "pnap_client_id" {
  project   = var.gcp_project_id
  secret_id = "pnap_client_id"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "pnap_client_id" {
  secret      = google_secret_manager_secret.pnap_client_id.id
  secret_data = var.pnap_client_id
}

resource "google_secret_manager_secret" "pnap_client_secret" {
  project   = var.gcp_project_id
  secret_id = "pnap_client_secret"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "pnap_client_secret" {
  secret      = google_secret_manager_secret.pnap_client_secret.id
  secret_data = var.pnap_client_secret
}

resource "google_secret_manager_secret" "pnap_server_config" {
  project   = var.gcp_project_id
  secret_id = "pnap_server_config"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "pnap_server_config" {
  secret = google_secret_manager_secret.pnap_server_config.id
  secret_data = jsonencode(
    {
      clusterName    = var.cluster_name
      gatewayAddress = cidrhost(var.network_details[var.network_details.primary_network].cidr, 1)
      hostname       = format("%s-worker-%02d", var.cluster_name, var.worker_node_count + 1)
      location       = var.pnap_location
      os             = var.operating_system
      privateNetwork = {
        id = var.network_details.private_network.id
        ip = cidrhost(var.network_details.private_network.cidr, var.worker_node_count + 5)
      },
      publicNetwork = {
        id   = var.network_details.public_network.id
        ip   = cidrhost(var.network_details.public_network.cidr, var.worker_node_count + 5)
        cidr = var.network_details.public_network.cidr
      },
      ssh_private_key = base64encode(var.ssh_key.private_key)
      ssh_public_key  = var.ssh_key.public_key
      type            = var.pnap_worker_type
      username        = var.username
    }
  )
}

resource "google_secret_manager_secret" "kubeconfig" {
  project   = var.gcp_project_id
  secret_id = "kubeconfig"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "kubeconfig" {
  secret      = google_secret_manager_secret.kubeconfig.id
  secret_data = var.kubeconfig
}
