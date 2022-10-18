# Closed-loop monitoring & remediation using Datadog, Eventarc, & Cloud functions (Tutorial)
## Create Accounts (STEP 1)
You will need to have/create three accounts:
* [PhoenixNAP](https://phoenixnap.com/bare-metal-cloud)
* [Google Cloud Account](https://console.cloud.google.com/) - New accounts get a $300 Google Cloud credit
  * You can use the default Google Cloud Project after you create a Google Cloud accoumt.
* [Datadog](https://www.datadoghq.com/free-datadog-trial/)
* Some Domain
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
Run the following command in the cloud shell
```bash
bash scripts/deploy.sh
```
This script will do almost everything for you, it will automatically pause and ask you to do the following two steps:
* Adding the EventArc integration to DataDog
  * Login to the DataDog App
  * Click Itegrations > Integrations
  * Search for "EventArc"
  * On the EventArc "Card" click "+ Available"
  * Click on the "Configure" Tab
  * Click on "+ Add New"
  * Fill out the "CHANNEL FULL NAME" & "ACTIVATION TOKEN"
  * Click the checkmark
* Setting you Name Servers (NS) for you domain or sub-domain
  * This is different for every registrar, you'll need to refer to their documentation

Once those steps are confirmed you must type exactly "Setup Complete!" and strike enter, and the rest of the deployment will continue. This could take aroun 45 minutes.
