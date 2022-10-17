

output "ssh_command_for_pnap" {
  value       = module.baremetal-anthos-cluster.ssh_command
  description = "Command to run to SSH into the bastion host"
}

output "ssh_key_path" {
  value       = module.baremetal-anthos-cluster.ssh_key_path
  description = "Path to the SSH Private key for the bastion host"
}

output "bastion_ip" {
  value       = module.baremetal-anthos-cluster.bastion_host_ip
  description = "IP Address of the bastion host in the test environment"
}

output "bastion_username" {
  value       = module.baremetal-anthos-cluster.bastion_host_username
  description = "Username for the bastion host in the test environment"
}

output "website" {
  value       = "https://${var.fqdn}"
  description = "The domain the website will be hosted on."
}

output "secret_manager_project_id" {
  description = "The secret manager project id"
  value       = module.google-secret-manager.secret_manager_project_id
}

output "kubeconig" {
  value = module.baremetal-anthos-cluster.kubeconfig
  sensitive = true
}