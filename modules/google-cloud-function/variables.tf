variable "gcp_project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "secret_manager_project_id" {
  description = "The project id for Google Secret Manager"
  type        = string
}

variable "cluster_name" {
  type        = string
  description = "The name of the kubernetes cluster"
}

variable "eventarc_topic" {
  type        = string
  description = "The Pub/Sub topic that is generated after the datadog integration"
}
