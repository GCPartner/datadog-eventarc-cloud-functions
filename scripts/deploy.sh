#!/usr/bin/env bash


# This script is intended to be run from the root of the git repository (http://cutt.ly/dash2022), like: bash /scripts/deploy.sh 
# Using the "Open in Google Cloud Shell" button is the easiest way to do this.


# Constant Variables
CHANNEL="dash2022"
REGION="us-central1"
CLUSTER_NAME="dash2022" # Must match RFC 952 hostname standard, 10 char maximum or REGEX: ^[a-z0-9]+(-[a-z0-9]+)$
DOMAIN="<my_domain_name>" # This must be a public DNS Zone that you own and can change the NS Records. A subdomin is fine like foo.bar.com
GCP_PROJECT_ID="<my_google_cloud_project>"
DATADOG_API_KEY="<my_datadog_api_key>"
DATADOG_APP_URL="<my_datadog_site>"
PNAP_CLIENT_ID="<my_pnap_client_id>"
PNAP_CLIENT_SECRET="<my_pnap_client_secret>"


# COLORS
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[34m"
BOLDRED="\e[1;${RED}"
BOLDGREEN="\e[1;${GREEN}"
BOLDBLUE="\e[1;${BLUE}"
ENDCOLOR="\e[0m"


function install_terraform () {
    mkdir -p $HOME/.local/bin
    wget https://releases.hashicorp.com/terraform/1.0.11/terraform_1.0.11_linux_amd64.zip
    unzip terraform_1.0.11_linux_amd64.zip
    sudo mv terraform $HOME/.local/bin/
    sudo rm -f terraform_1.0.11_linux_amd64.zip
    echo "PATH=$HOME/.local/bin:\$PATH" >> $HOME/.bashrc
    PATH=$HOME/.local/bin:$PATH
}


function set_project () {
    gcloud config set project $GCP_PROJECT_ID
}


function enable_apis () {
    apis=( 
        "artifactregistry.googleapis.com"
        "run.googleapis.com"
        "cloudfunctions.googleapis.com"
        "cloudbuild.googleapis.com"
        "dns.googleapis.com"
        "eventarc.googleapis.com"
        "eventarcpublishing.googleapis.com"
        "pubsub.googleapis.com"
        "secretmanager.googleapis.com"
    )
    for api in "${apis[@]}"; do
        gcloud services enable $api --async
    done
}


function setup_eventarc () {
    gcloud eventarc channels create $CHANNEL --provider datadog --location $REGION
    CHANNEL_FULL_NAME=`gcloud eventarc channels describe $CHANNEL --location $REGION | grep "name:" | awk '{print $2}'`
    DATADOG_ACTIVATION_TOKEN=`gcloud eventarc channels describe $CHANNEL --location $REGION | grep "activationToken:" | awk '{print $2}'`
    PUBSUB_TOPIC_NAME=`gcloud pubsub topics list | grep $CHANNEL | awk '{print $2}'`
}


function create_dns_zone () {
    ZONE_NAME=`echo "$DOMAIN" | tr . -`
    gcloud dns managed-zones create $ZONE_NAME --dns-name="$DOMAIN" --description="DNS Zone for Dash 2022"
    NS_SERVERS=`gcloud dns managed-zones describe $ZONE_NAME | grep "^-" | awk '{print $2}' |awk '{sub(/.$/,"")}1'`
}


function setup_terraform () {
    cat << EOF > terraform.tfvars
        pnap_client_id     = "$PNAP_CLIENT_ID"
        pnap_client_secret = "$PNAP_CLIENT_SECRET"
        gcp_project_id     = "$GCP_PROJECT_ID"
        datadog_api_key    = "$DATADOG_API_KEY"
        fqdn               = "$CLUSTER_NAME.$DOMAIN"
        cluster_name       = "$CLUSTER_NAME"
        datadog_site       = "$DATADOG_APP_URL"
        eventarc_topic     = "$PUBSUB_TOPIC_NAME"
EOF
    terraform fmt
    terraform init
}


function wait_for_user_confirmation () {
    cat << EOF


        There are a few manual things you need to do now.

        1) Login to your Datadog Dashboard and setup the EventArc integration:
            a. EventArc Full Channel Name: $(echo -e ${BOLDBLUE})$CHANNEL_FULL_NAME $(echo -e ${ENDCOLOR})
            b. EventArc Activation Token: $(echo -e ${BOLDBLUE})$DATADOG_ACTIVATION_TOKEN $(echo -e ${ENDCOLOR})
        2) Setup your DNS Zone with the following Name Servers:
        $(echo -e ${BOLDGREEN})
`for ns in $NS_SERVERS; do echo "           $ns"; done`
        $(echo -e ${ENDCOLOR})
        Once this is done...


EOF
    while :; do
        echo -e "Type exactly ${GREEN}'Setup Complete!'${ENDCOLOR} and press {Enter}:"
        read -p "" user_input
        if [ "$user_input" == "Setup Complete!" ]; then
            break
        else
            echo -e "${BOLDRED}Inorrect input, if you would like to cancel, press Ctrl+C${ENDCOLOR}"
        fi
    done
}


function run_terraform () {
    terraform apply --auto-approve
}


# Call functions
install_terraform
set_project
enable_apis
setup_eventarc
create_dns_zone
setup_terraform
wait_for_user_confirmation
run_terraform

