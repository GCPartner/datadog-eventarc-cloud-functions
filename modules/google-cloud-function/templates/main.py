import base64
import datetime
import functions_framework
import json
import pnap_bmc_api
import paramiko
from io import StringIO
from pnap_bmc_api.api import servers_api
from pnap_bmc_api.model.ip_blocks_configuration import IpBlocksConfiguration
from pnap_bmc_api.model.network_configuration import NetworkConfiguration
from pnap_bmc_api.model.private_network_configuration import PrivateNetworkConfiguration
from pnap_bmc_api.model.public_network_configuration import PublicNetworkConfiguration
from pnap_bmc_api.model.server_create import ServerCreate
from pnap_bmc_api.model.server_private_network import ServerPrivateNetwork
from pnap_bmc_api.model.server_public_network import ServerPublicNetwork
from google.cloud import secretmanager 
from keycloak.keycloak_openid import KeycloakOpenID
from kubernetes import client, config


SECRET_MANAGER_PROJECT_ID = "${secret_manager_project_id}"
PNAP_BMC_PROD_URL = "https://api.phoenixnap.com/bmc/v1"


def get_pnap_auth_token(client_id: str, client_secret: str,
                        server_url: str = "https://auth.phoenixnap.com/auth/",
                        realm_name: str = "BMC", grant_type: str = "client_credentials") -> str:
    print("Fetching PNAP Auth Token")
    keycloakOpenId = KeycloakOpenID(server_url=server_url, realm_name=realm_name,
                                    client_id=client_id, client_secret_key=client_secret)
    access_token = keycloakOpenId.token(grant_type=grant_type)['access_token']
    return access_token


def get_gcp_secret(secret: str) -> str:
    print(f"Fetching secret: {secret}, from GCP")
    client = secretmanager.SecretManagerServiceClient()
    secret_path = f"projects/{SECRET_MANAGER_PROJECT_ID}/secrets/{secret}/versions/1"
    response = client.access_secret_version(request={"name": secret_path})
    payload = response.payload.data.decode("UTF-8")
    return payload


def create_server(access_token, pnap_server_config: object):
    print(f"Creating server {pnap_server_config['hostname']}")
    server_create = ServerCreate(
        hostname=pnap_server_config['hostname'],
        os=pnap_server_config['os'],
        type=pnap_server_config['type'],
        location=pnap_server_config['location'],
        install_default_ssh_keys=True,
        ssh_keys=[pnap_server_config['ssh_public_key']],
        pricing_model="HOURLY",
        network_type="PUBLIC_AND_PRIVATE",
        network_configuration=NetworkConfiguration(
            gateway_address=pnap_server_config['gatewayAddress'],
            ip_blocks_configuration=IpBlocksConfiguration(
                configuration_type="NONE"
            ),
            private_network_configuration=PrivateNetworkConfiguration(
                configuration_type="USER_DEFINED",
                private_networks=[
                    ServerPrivateNetwork(
                        id=pnap_server_config['privateNetwork']['id'],
                        ips=[pnap_server_config['privateNetwork']['ip']],
                        dhcp=False
                    )
                ]
            ),
            public_network_configuration=PublicNetworkConfiguration(
                public_networks=[
                    ServerPublicNetwork(
                        id=pnap_server_config['publicNetwork']['id'],
                        cidrs = [pnap_server_config['publicNetwork']['cidr']],
                        ips = [pnap_server_config['publicNetwork']['ip']]
                    )
                ]
            )
        )
    )
    pnap_config = pnap_bmc_api.Configuration(host=PNAP_BMC_PROD_URL, access_token=access_token)
    with pnap_bmc_api.ApiClient(pnap_config) as api_client:
        api_instance = servers_api.ServersApi(api_client)
        api_response = api_instance.servers_post(server_create=server_create)
    return api_response


def ssh_connection(host, username, private_key):
    print(f"Checking if SSH is accpeting connections for ip: {host}")
    success = False
    try:
        key = paramiko.RSAKey.from_private_key(StringIO(private_key))
        connect = paramiko.SSHClient()
        connect.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        connect.connect(hostname=host, username=username, pkey=key)
        success = True
    except Exception:
        success = False
    print(f"SSH is listening for ip: {host}!")
    return success


def add_server_to_cluster(server_ip, cluster_name, kubeconfig):
    print("Adding node to Anthos cluster")
    config.load_kube_config(StringIO(kubeconfig))
    api = client.CustomObjectsApi()
    api.api_client.set_default_header('Content-Type', 'application/json-patch+json')
    body = [{"op": "add", "path": "/spec/nodes/3", "value": {"address": server_ip}}]
    response = api.patch_namespaced_custom_object(group="baremetal.cluster.gke.io",
                                                  version="v1",
                                                  namespace=f"cluster-{cluster_name}",
                                                  plural="nodepools", name="node-pool-1",
                                                  body=body)


@functions_framework.http
def main(request):
    pnap_client_id = get_gcp_secret('pnap_client_id')
    pnap_client_secret = get_gcp_secret('pnap_client_secret')
    pnap_server_config = json.loads(get_gcp_secret('pnap_server_config'))
    kubeconfig = get_gcp_secret('kubeconfig')
    access_token = get_pnap_auth_token(pnap_client_id, pnap_client_secret)
    server=create_server(access_token, pnap_server_config)
    ssh_connection(pnap_server_config['publicNetwork']['ip'], pnap_server_config['username'], 
                   base64.b64decode(pnap_server_config['ssh_private_key']).decode('utf-8'))
    add_server_to_cluster(pnap_server_config['publicNetwork']['ip'], pnap_server_config['clusterName'], kubeconfig)
    print("Done!")
    return("We win!")