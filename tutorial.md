# Closed-loop monitoring & remediation using Datadog, Eventarc, & Cloud functions (Tutorial)
## Prerequisits (STEP 1)
You will need to have/create three accounts, and a domain:
* [PhoenixNAP](https://phoenixnap.com/bare-metal-cloud)
* [Google Cloud Account](https://console.cloud.google.com/) - New accounts get a $300 Google Cloud credit
  * You can use the default Google Cloud Project after you create a Google Cloud accoumt.
* [Datadog](https://www.datadoghq.com/free-datadog-trial/)
* Domain
  * You will need a valid domain or sub-domain
  * You could use [Google Cloud Domain](https://cloud.google.com/domains/docs/register-domain)
  * If using cloud domains, you may get an error in subsiquent steps when we try and create the Cloud DNS Zone, just ignore this.
## Gather information (STEP 2)
We will not be documenting step by step how to gather this information, please refer to each providers own documentation.
### PhoenixNAP
* Client ID
  * Example: 9d54443b-6f6e-41a8-a556-86d66ed0aa97
* Client Secret
  * Example: 4c804cc9-7731-4a80-8a55-aa1a6291082c

Read more [here](https://developers.phoenixnap.com/quick-start)
### Google Cloud Account
* GCP Project ID
  * Example: my-gcp-project-id
 
Read more [here](https://cloud.google.com/resource-manager/docs/creating-managing-projects)
### Datadog
* DataDog App URL
  * Example: us5.datadoghq.com
* DataDog API Key
  * Example: f49d29bcf95f40ada481d4aa006a9a71

Read more [here](https://docs.datadoghq.com/account_management/api-app-keys)
### Domain
* Your domain or subdomain url
  * Example: foo.bar.com
## Edit the deploy.sh script (STEP 3)
You will need to use the information gathered in Step 2 and edit `scripts/deploy.sh` (which should be open in the cloud shell editor) and populate the following values at the top of the script:
```bash

DOMAIN="<my_domain_name>"
GCP_PROJECT_ID="<my_google_cloud_project>"
DATADOG_API_KEY="<my_datadog_api_key>"
DATADOG_APP_URL="<my_datadog_site>"
PNAP_CLIENT_ID="<my_pnap_client_id>"
PNAP_CLIENT_SECRET="<my_pnap_client_secret>"
```
## Run the deployment script (STEP 4)
Run the following command in the cloud shell to begin the deployment
```bash
bash scripts/deploy.sh
```
## Finish the configuration (STEP 5)
The script executed in the previous step will do almost everything for you, it will automatically pause and ask you to do the following two steps:
* Adding the EventArc integration to DataDog
  * Login to the DataDog App
  * Click Integrations > Integrations
  * Search for "EventArc"
  * On the EventArc "Card" click "+ Available"
  * Click on the "Configure" Tab
  * Click on "+ Add New"
  * Fill out the "CHANNEL FULL NAME" & "ACTIVATION TOKEN"
    * These values will be automatically printed to the screen once the script has been run
  * Click the checkmark
* Setting you Name Servers (NS) for you domain or sub-domain
  * This is different for every registrar, you'll need to refer to their documentation
    * These values will be automatically printed to the screen once the script has been run

Once those steps are confirmed you must type exactly "Setup Complete!" and strike enter, and the rest of the deployment will continue. This could take around 45 minutes.

## Setup your monitor in DataDog (STEP 6)
* Login to the DataDog App
* Click Monitors > New Monitor
* Click Metric
* Under "Define the metric" type in `system.cpu.system` in the "a" field
* In the "from" field search for and select `kube_cluster_name:<your_cluster_name>`
* Under set alert conditions, set:
  * Trigger when the evaluated value is `above` the threshold
  * alert threshold: `10`
* Under Notify your team:
  * Click on the dropdown menu that says "Notify your services and team members" and select the `eventarc-<project_id>_<region>_<channel_name>`
  * Right below the word `Edit` name your monitor something like `System CPU Average for <cluster_name>`
* Leave everything else default, and click "Create"

## Done
Now that all of this is setup, DataDog will monitor for the CPU threshold. If the combined CPU of your nodes rise above the threshold that you have configured in "Step 6", the alert will be trigged. Then DataDog will send a message to EventArc and trigger Cloud Functions to add an additional node to your cluster. 

The monitor will take some time to collect metrics, so please be paitent.

## Clean Up Steps
If your function is triggered and an additional node is added to PhoenixNAP, since that node is not tracked by Terraform, you must delete this node manually through the PhoenixNAP console.

After that node is removed, you can simply run the following command from the cloud shell
```bash
terraform destroy --auto-approve
```
This will cleanup everything but:
* The DataDog Monitor
* EventArc Integration in DataDog
* The EventArc channel in Google Cloud
* Cloud DNS Zones and Records
You can clean these up manually in that order. 

If for some reason the `terraform destroy` errors, login to the PhoenixNAP console and delele the following in order:
* Servers
* Public Network
* Private Network
* Public IP Allocations

It would probably also be a good idea to verify these are cleaned up even if terraform doesn't error, as the cluster could cost you upwards of $60 per day.

To cleanup GCP in the event that the `terraform destroy` errors, I would suggest deleting the entire project.


Thank you!

