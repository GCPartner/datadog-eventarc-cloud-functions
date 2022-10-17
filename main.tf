module "baremetal-anthos-cluster" {
  source             = "github.com/GCPartner/terraform-gcpartner-anthos-baremetal"
  cluster_name       = var.cluster_name
  cloud              = var.cloud
  pnap_client_id     = var.pnap_client_id
  pnap_client_secret = var.pnap_client_secret
  pnap_location      = var.pnap_location
  pnap_worker_type   = var.pnap_worker_type
  pnap_cp_type       = var.pnap_cp_type
  gcp_project_id     = var.gcp_project_id
  worker_node_count  = var.worker_node_count
  operating_system   = var.operating_system
}

module "google-cloud-dns" {
  source         = "./modules/google-cloud-dns"
  cluster_name   = module.baremetal-anthos-cluster.cluster_name
  gcp_project_id = var.gcp_project_id
}

module "on-prem-services" {
  depends_on = [
    module.baremetal-anthos-cluster
  ]
  source          = "./modules/on-prem-services"
  ssh_key_path    = module.baremetal-anthos-cluster.ssh_key_path
  bastion_ip      = module.baremetal-anthos-cluster.bastion_host_ip
  username        = module.baremetal-anthos-cluster.bastion_host_username
  cluster_name    = module.baremetal-anthos-cluster.cluster_name
  fqdn            = var.fqdn
  datadog_api_key = var.datadog_api_key
  gcp_project_id  = var.gcp_project_id
  cloud_dns_sa    = module.google-cloud-dns.cloud_dns_sa_key
  datadog_site    = var.datadog_site
}

module "google-secret-manager" {
  depends_on = [
    module.baremetal-anthos-cluster
  ]
  source             = "./modules/google-secret-manager"
  pnap_client_id     = var.pnap_client_id
  pnap_client_secret = var.pnap_client_secret
  cluster_name       = module.baremetal-anthos-cluster.cluster_name
  bastion_ip         = module.baremetal-anthos-cluster.bastion_host_ip
  username           = module.baremetal-anthos-cluster.bastion_host_username
  worker_node_count  = var.worker_node_count
  pnap_location      = var.pnap_location
  operating_system   = module.baremetal-anthos-cluster.os_image
  ssh_key            = module.baremetal-anthos-cluster.ssh_key
  pnap_worker_type   = var.pnap_worker_type
  kubeconfig         = module.baremetal-anthos-cluster.kubeconfig
  network_details    = module.baremetal-anthos-cluster.network_details
  gcp_project_id     = var.gcp_project_id
}

module "google-cloud-function" {
  depends_on = [
    module.google-secret-manager
  ]
  source                    = "./modules/google-cloud-function"
  gcp_project_id            = var.gcp_project_id
  cluster_name              = module.baremetal-anthos-cluster.cluster_name
  secret_manager_project_id = module.google-secret-manager.secret_manager_project_id
  eventarc_topic             = var.eventarc_topic
}