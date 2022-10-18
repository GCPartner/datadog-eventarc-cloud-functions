locals {
  cloud_function_output_file = "${path.root}/function-source.zip"
  gcp_region                 = "us-central1"
  cloud_function_name        = "scale-up-${var.cluster_name}"
}

resource "google_project_service" "enable_artifact_registry_api" {
  project            = var.gcp_project_id
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
  provisioner "local-exec" {
    command = "sleep 15"
  }
}

resource "google_project_service" "enable_cloud_run_api" {
  depends_on = [
    google_project_service.enable_artifact_registry_api
  ]
  project            = var.gcp_project_id
  service            = "run.googleapis.com"
  disable_on_destroy = false
  provisioner "local-exec" {
    command = "sleep 15"
  }
}

resource "google_project_service" "enable_cloud_function_api" {
  depends_on = [
    google_project_service.enable_cloud_run_api
  ]
  project            = var.gcp_project_id
  service            = "cloudfunctions.googleapis.com"
  disable_on_destroy = false
  provisioner "local-exec" {
    command = "sleep 15"
  }
}

data "template_file" "main_py" {
  template = file("${path.module}/templates/main.py")
  vars = {
    secret_manager_project_id = var.secret_manager_project_id
  }
}

data "archive_file" "dotfiles" {
  type        = "zip"
  output_path = local.cloud_function_output_file

  source {
    content  = data.template_file.main_py.rendered
    filename = "main.py"
  }

  source {
    content  = file("${path.module}/templates/requirements.txt")
    filename = "requirements.txt"
  }
}

resource "google_storage_bucket" "bucket" {
  name                        = "${var.gcp_project_id}-${var.cluster_name}-source"
  project                     = var.gcp_project_id
  location                    = "US"
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_object" "object" {
  name   = "function-source.zip"
  bucket = google_storage_bucket.bucket.name
  source = "function-source.zip"
}

resource "google_service_account" "cloud-function-service-account" {
  account_id   = "sa-cf-${var.cluster_name}"
  project      = var.gcp_project_id
  display_name = "Service account to access secret manager for function: ${local.cloud_function_name}"
}

resource "google_project_iam_member" "role_assignment" {
  role    = "roles/secretmanager.secretAccessor"
  member  = format("serviceAccount:%s", google_service_account.cloud-function-service-account.email)
  project = var.gcp_project_id
}

resource "google_cloudfunctions2_function" "function" {
  depends_on = [
    google_project_service.enable_cloud_function_api
  ]
  name        = local.cloud_function_name
  project     = var.gcp_project_id
  location    = local.gcp_region
  description = "This function will get triggered by EventArc and scale up K8s cluster: ${var.cluster_name}"

  build_config {
    runtime     = "python38"
    entry_point = "main"
    source {
      storage_source {
        bucket = google_storage_bucket.bucket.name
        object = google_storage_bucket_object.object.name
      }
    }
  }
  service_config {
    service_account_email = google_service_account.cloud-function-service-account.email
    available_memory      = "256M"
    max_instance_count    = 100
    timeout_seconds       = 60
  }
  event_trigger {
    trigger_region = local.gcp_region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = var.eventarc_topic
    retry_policy   = "RETRY_POLICY_DO_NOT_RETRY"
  }
}
