variable "ssh_key_path" {
  description = "SSH Public and Private Key"
}

variable "bastion_ip" {
  type        = string
  description = "The bastion host/admin workstation public IP Address"
}

variable "username" {
  type        = string
  description = "The username used to ssh to hosts"
}

variable "datadog_api_key" {
  type        = string
  description = "The datadog api key"
}

variable "cluster_name" {
  type        = string
  description = "The name of the kubernetes cluster"
}

variable "gcp_project_id" {
  type        = string
  description = "The GCP project id"
}

variable "fqdn" {
  type        = string
  description = "The fully qualified domain name for the frontend"
}

variable "cloud_dns_sa" {
  type        = string
  description = "The JSON Key for the Service Accuont for Cloud DNS access"
}

variable "datadog_site" {
  type        = string
  description = "The datadog api key"
}