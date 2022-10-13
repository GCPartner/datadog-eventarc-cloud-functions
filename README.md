# datadog-eventarc-cloud-functions
All code to replicate the Demo given during DataDog Dash 2022 in NYC
[![Anthos Website](https://img.shields.io/badge/Website-cloud.google.com/anthos-blue)](https://cloud.google.com/anthos) [![Apache License](https://img.shields.io/github/license/GCPartner/phoenixnap-megaport-anthos)](https://github.com/GCPartner/phoenixnap-megaport-anthos/blob/main/LICENSE) [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](https://github.com/GCPartner/phoenixnap-megaport-anthos/pulls) ![](https://img.shields.io/badge/Stability-Experimental-red.svg)
# Closed-loop monitoring & remediation of issues using Datadog, Eventarc, & Cloud functions
This [Terraform](http://terraform.io) module will allow you to deploy [Google Cloud's Anthos on Baremetal](https://cloud.google.com/anthos) on [PhoenixNAP](http://phoenixnap.com), Cloud Functions and Eventarc on [Google Cloud](https://cloud.google.com). This module then deploys a [MicroServices](https://github.com/GoogleCloudPlatform/microservices-demo) application spanning both Kubernetes clusters. With the web frontend and middlware, and the backend database being hosted on an Anthos Cluster on  PhoenixNAP's Bare Metal Cloud. We then use [External DNS](https://github.com/kubernetes-sigs/external-dns) to create DNS records on the fly for our website, and [Cert Manager](https://cert-manager.io/) to get a valid SSL Certificate as well.

## Prerequisites 
### Software to Install
`Only Linux has been tested`
* [gcloud command line](https://cloud.google.com/sdk/docs/install)
* [terraform](https://www.terraform.io/downloads)
* [helm](https://helm.sh/docs/intro/install/)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)
* [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

### Accounts Needed
* [PhoenixNAP](https://phoenixnap.com/bare-metal-cloud)
* [Google Cloud Account](https://console.cloud.google.com/)
* [Datadog](https://www.datadoghq.com/free-datadog-trial/)

### Other
* A domain name or subdomain you control DNS for
### Information to Gather
#### PhoenixNAP
* Client ID
* Client Secret
* Location
* Private Network Name
* Backend MegaPort Mapping vLan ID
#### Google Cloud
* Project ID
* Region

#### Other
* E-Mail Address
* Domain Name(FQDN)

## Deployment
### Authenticate to Google Cloud
```bash
gcloud init # Follow any prompts
gcloud auth application-default login # Follown any prompts
```
### Clone the Repo
```bash
git clone https://github.com/GCPartner/phoenixnap-megaport-anthos.git
cd phoenixnap-megaport-anthos
```
### Create your *terraform.tfvars*
The following values will need to be modified by you.
```bash
cat <<EOF >terraform.tfvars 
cluster_name                  = "my-cluster"
domain_name                   = "my.domain.tld"
email_address                 = "my@email.tld"
pnap_client_id                = "******"
pnap_client_secret            = "******"
pnap_network_name             = "PNAP-Private-Network-Name" # Created ahead of time in PNAP
pnap_backend_megaport_vlan_id = 13 # Provided by PNAP
gcp_project_id                = "my-project" # Created ahead of time in GCP
megaport_username             = "my@email.tld"
megaport_password             = "******"
megaport_physical_port_id     = "ee03c69b-319c-411d-abd9-03eb999bafda" # Provided by PNAP
EOF
```
### Initialize Terraform
```bash
terraform init
```
### Deploy the stack
```bash
terraform apply --auto-approve
```
### What success looks like
```
Apply complete! Resources: 78 added, 0 changed, 0 destroyed.

Outputs:

pnap_bastion_host_ip = "131.153.202.107"
pnap_bastion_host_username = "ubuntu"
ssh_command_for_pnap = "ssh -i /home/c0dyhi11/.ssh/anthos-pnap-lunch-xj62n ubuntu@131.153.202.107"
ssh_key_path = "/home/c0dyhi11/.ssh/anthos-pnap-lunch-xj62n"
website = "https://test1.codyhill.org"
```
<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name(s) of the clusters to be deployed | `string` | `"my-cluster"` | no |
| <a name="input_cloud"></a> [cloud](#input\_cloud) | The Cloud to deploy the Baremetal cluster on | `string` | `"PNAP"` | no |
| <a name="input_pnap_client_id"></a> [pnap\_client\_id](#input\_pnap\_client\_id) | The client id for authentication to pnap | `string` | n/a | yes |
| <a name="input_pnap_client_secret"></a> [pnap\_client\_secret](#input\_pnap\_client\_secret) | The client secret for authentication to pnap | `string` | n/a | yes |
| <a name="input_pnap_location"></a> [pnap\_location](#input\_pnap\_location) | The pnap region to deploy nodes to | `string` | `"PHX"` | no |
| <a name="input_pnap_worker_type"></a> [pnap\_worker\_type](#input\_pnap\_worker\_type) | The type of PNAP server to deploy for worker nodes | `string` | `"s2.c1.medium"` | no |
| <a name="input_pnap_cp_type"></a> [pnap\_cp\_type](#input\_pnap\_cp\_type) | The type of PNAP server to deploy for control plane nodes | `string` | `"s2.c1.medium"` | no |
| <a name="input_gcp_project_id"></a> [gcp\_project\_id](#input\_gcp\_project\_id) | The GCP Project ID | `string` | n/a | yes |
| <a name="input_ansible_url"></a> [ansible\_url](#input\_ansible\_url) | The Ansible URL for the Anthos Automation | `string` | `"https://github.com/GCPartner/ansible-gcpartner-anthos-baremetal/archive/refs/heads/v0.0.1.tar.gz"` | no |
| <a name="input_ansible_tar_ball"></a> [ansible\_tar\_ball](#input\_ansible\_tar\_ball) | The name of the ansible tarball | `string` | `"v0.0.1.tar.gz"` | no |
| <a name="input_gcp_region"></a> [gcp\_region](#input\_gcp\_region) | The GCP Region | `string` | `"us-west4"` | no |
| <a name="input_gke_node_count"></a> [gke\_node\_count](#input\_gke\_node\_count) | The number of worker nodes for the GKE cluster | `number` | `1` | no |
| <a name="input_gke_release_channel"></a> [gke\_release\_channel](#input\_gke\_release\_channel) | The requested asn for Megaport | `string` | `"RAPID"` | no |
| <a name="input_gke_machine_type"></a> [gke\_machine\_type](#input\_gke\_machine\_type) | The requested asn for Megaport | `string` | `"c2-standard-4"` | no |
| <a name="input_gcp_router_asn"></a> [gcp\_router\_asn](#input\_gcp\_router\_asn) | The requested asn for Megaport | `number` | `16550` | no |
| <a name="input_megaport_requested_asn"></a> [megaport\_requested\_asn](#input\_megaport\_requested\_asn) | The requested asn for Megaport | `number` | `64555` | no |
| <a name="input_megaport_username"></a> [megaport\_username](#input\_megaport\_username) | The username for Megaport | `string` | n/a | yes |
| <a name="input_megaport_password"></a> [megaport\_password](#input\_megaport\_password) | The password for Megaport | `string` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The domain name to use for DNS records | `string` | n/a | yes |
| <a name="input_cert_manager_version"></a> [cert\_manager\_version](#input\_cert\_manager\_version) | The version of cert manager to install | `string` | `"v1.8.0"` | no |
| <a name="input_email_address"></a> [email\_address](#input\_email\_address) | The email address to use with Cert Manager | `string` | n/a | yes |
| <a name="input_pnap_network_name"></a> [pnap\_network\_name](#input\_pnap\_network\_name) | The network\_id to use when creating server in PNAP | `string` | `""` | no |
| <a name="input_pnap_backend_megaport_vlan_id"></a> [pnap\_backend\_megaport\_vlan\_id](#input\_pnap\_backend\_megaport\_vlan\_id) | The vLan ID mapped on the MegaPort side by PNAP (Provided by PNAP) | `number` | n/a | yes |
| <a name="input_megaport_physical_port_id"></a> [megaport\_physical\_port\_id](#input\_megaport\_physical\_port\_id) | The Physical Port ID you'll use on within the PhoenixNAP DC to connect to MegaPort | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ssh_command_for_pnap"></a> [ssh\_command\_for\_pnap](#output\_ssh\_command\_for\_pnap) | Command to run to SSH into the bastion host |
| <a name="output_ssh_key_path"></a> [ssh\_key\_path](#output\_ssh\_key\_path) | Path to the SSH Private key for the bastion host |
| <a name="output_pnap_bastion_host_ip"></a> [pnap\_bastion\_host\_ip](#output\_pnap\_bastion\_host\_ip) | IP Address of the bastion host in the test environment |
| <a name="output_pnap_bastion_host_username"></a> [pnap\_bastion\_host\_username](#output\_pnap\_bastion\_host\_username) | Username for the bastion host in the test environment |
| <a name="output_website"></a> [website](#output\_website) | The domain the website will be hosted on. |
<!-- END_TF_DOCS -->
