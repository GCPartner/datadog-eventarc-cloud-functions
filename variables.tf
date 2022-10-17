variable "cluster_name" {
  description = "The name(s) of the clusters to be deployed"
  type        = string
  default     = "dash"
}

variable "cloud" {
  description = "The Cloud to deploy the Baremetal cluster on"
  type        = string
  default     = "PNAP"
}

variable "pnap_client_id" {
  description = "The client id for authentication to pnap"
  type        = string
}

variable "pnap_client_secret" {
  description = "The client secret for authentication to pnap"
  type        = string
}

variable "pnap_location" {
  description = "The pnap region to deploy nodes to"
  type        = string
  default     = "ASH"
}

variable "pnap_worker_type" {
  description = "The type of PNAP server to deploy for worker nodes"
  type        = string
  default     = "s2.c1.medium"
}

variable "pnap_cp_type" {
  description = "The type of PNAP server to deploy for control plane nodes"
  type        = string
  default     = "s2.c1.medium"
}

variable "gcp_project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "datadog_api_key" {
  type        = string
  description = "The datadog api key"
}

variable "datadog_site" {
  type        = string
  description = "The datadog api key"
}

variable "fqdn" {
  type        = string
  description = "The fully qualified domain name for the frontend"
}

variable "worker_node_count" {
  type        = number
  default     = 3
  description = "How many worker nodes to deploy"
}

variable "operating_system" {
  type        = string
  default     = "ubuntu_20_04"
  description = "The Operating system to deploy (Only ubuntu_20_04 has been tested)"
}

variable "eventarc_topic" {
  type = string
  description = "The Pub/Sub topic that is generated after the datadog integration"
}
