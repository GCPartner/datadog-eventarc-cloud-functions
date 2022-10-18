# Closed-loop monitoring & remediation of issues using Datadog, Eventarc, & Cloud functions

[![Anthos Website](https://img.shields.io/badge/Website-cloud.google.com/anthos-blue)](https://cloud.google.com/anthos) [![Apache License](https://img.shields.io/github/license/GCPartner/phoenixnap-megaport-anthos)](https://github.com/GCPartner/phoenixnap-megaport-anthos/blob/main/LICENSE) [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat-square)](https://github.com/GCPartner/phoenixnap-megaport-anthos/pulls) ![](https://img.shields.io/badge/Stability-Experimental-red.svg)

This [Terraform](http://terraform.io) module will allow you to deploy [Google Cloud's Anthos on Baremetal](https://cloud.google.com/anthos) on [PhoenixNAP](http://phoenixnap.com), Cloud Functions and Eventarc on [Google Cloud](https://cloud.google.com). This module then deploys a [MicroServices](https://github.com/GoogleCloudPlatform/microservices-demo) application, with the web frontend and middlware, and the backend database being hosted on an Anthos Cluster on  PhoenixNAP's Bare Metal Cloud. We then use [External DNS](https://github.com/kubernetes-sigs/external-dns) to create DNS records on the fly for our website, and [Cert Manager](https://cert-manager.io/) to get a valid SSL Certificate as well.

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://shell.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https%3A%2F%2Fgithub.com%2FGCPartner%2Fdatadog-eventarc-cloud-functions&cloudshell_open_in_editor=scripts%2Fdeploy.sh&cloudshell_tutorial=tutorial.md)

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
>>>>>>> e0526c63c9c4d9d7c2968b43a506d18daeb70bcb
<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name(s) of the clusters to be deployed | `string` | `"dash"` | no |
| <a name="input_cloud"></a> [cloud](#input\_cloud) | The Cloud to deploy the Baremetal cluster on | `string` | `"PNAP"` | no |
| <a name="input_pnap_client_id"></a> [pnap\_client\_id](#input\_pnap\_client\_id) | The client id for authentication to pnap | `string` | n/a | yes |
| <a name="input_pnap_client_secret"></a> [pnap\_client\_secret](#input\_pnap\_client\_secret) | The client secret for authentication to pnap | `string` | n/a | yes |
| <a name="input_pnap_location"></a> [pnap\_location](#input\_pnap\_location) | The pnap region to deploy nodes to | `string` | `"ASH"` | no |
| <a name="input_pnap_worker_type"></a> [pnap\_worker\_type](#input\_pnap\_worker\_type) | The type of PNAP server to deploy for worker nodes | `string` | `"s2.c1.medium"` | no |
| <a name="input_pnap_cp_type"></a> [pnap\_cp\_type](#input\_pnap\_cp\_type) | The type of PNAP server to deploy for control plane nodes | `string` | `"s2.c1.medium"` | no |
| <a name="input_gcp_project_id"></a> [gcp\_project\_id](#input\_gcp\_project\_id) | The GCP Project ID | `string` | n/a | yes |
| <a name="input_datadog_api_key"></a> [datadog\_api\_key](#input\_datadog\_api\_key) | The datadog api key | `string` | n/a | yes |
| <a name="input_datadog_site"></a> [datadog\_site](#input\_datadog\_site) | The datadog api key | `string` | n/a | yes |
| <a name="input_fqdn"></a> [fqdn](#input\_fqdn) | The fully qualified domain name for the frontend | `string` | n/a | yes |
| <a name="input_worker_node_count"></a> [worker\_node\_count](#input\_worker\_node\_count) | How many worker nodes to deploy | `number` | `3` | no |
| <a name="input_operating_system"></a> [operating\_system](#input\_operating\_system) | The Operating system to deploy (Only ubuntu\_20\_04 has been tested) | `string` | `"ubuntu_20_04"` | no |
| <a name="input_eventarc_topic"></a> [eventarc\_topic](#input\_eventarc\_topic) | The Pub/Sub topic that is generated after the datadog integration | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ssh_command_for_pnap"></a> [ssh\_command\_for\_pnap](#output\_ssh\_command\_for\_pnap) | Command to run to SSH into the bastion host |
| <a name="output_ssh_key_path"></a> [ssh\_key\_path](#output\_ssh\_key\_path) | Path to the SSH Private key for the bastion host |
| <a name="output_bastion_ip"></a> [bastion\_ip](#output\_bastion\_ip) | IP Address of the bastion host in the test environment |
| <a name="output_bastion_username"></a> [bastion\_username](#output\_bastion\_username) | Username for the bastion host in the test environment |
| <a name="output_website"></a> [website](#output\_website) | The domain the website will be hosted on. |
<!-- END_TF_DOCS -->
