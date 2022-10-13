variable "pnap_client_id" {
  description = "The client id for authentication to pnap"
  type        = string
}

variable "pnap_client_secret" {
  description = "The client secret for authentication to pnap"
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster to be deployed"
  type        = string
}

variable "bastion_ip" {
  type        = string
  description = "The bastion host/admin workstation public IP Address"
}

variable "username" {
  type        = string
  description = "The username used to ssh to hosts"
}

variable "worker_node_count" {
  type        = number
  default     = 3
  description = "How many worker nodes to deploy"
}

variable "pnap_location" {
  description = "The pnap region to deploy nodes to"
  type        = string
}

variable "operating_system" {
  type        = string
  description = "The Operating system to deploy (Only ubuntu_20_04 has been tested)"
}

variable "ssh_key" {
  type = object({
    public_key  = string
    private_key = string
  })
  description = "SSH Public and Private Key"
}

variable "pnap_worker_type" {
  description = "The type of PNAP server to deploy for worker nodes"
  type        = string
  default     = "s2.c1.medium"
}

variable "kubeconfig" {
  type        = string
  description = "The kubeconfig for the anthos cluster"

}

variable "network_details" {
  type = object({
    primary_network = string
    private_network = object({
      id      = string
      vlan_id = string
      cidr    = string
    })
    public_network = object({
      id      = string
      vlan_id = string
      cidr    = string
    })
  })
  description = "The network details for the kubernetes cluster"
}

variable "gcp_project_id" {
  type        = string
  description = "The GCP project id"
}
