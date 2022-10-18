<!-- BEGIN_TF_DOCS -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gcp_project_id"></a> [gcp\_project\_id](#input\_gcp\_project\_id) | The GCP Project ID | `string` | n/a | yes |
| <a name="input_secret_manager_project_id"></a> [secret\_manager\_project\_id](#input\_secret\_manager\_project\_id) | The project id for Google Secret Manager | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | The name of the kubernetes cluster | `string` | n/a | yes |
| <a name="input_eventarc_topic"></a> [eventarc\_topic](#input\_eventarc\_topic) | The Pub/Sub topic that is generated after the datadog integration | `string` | n/a | yes |
<!-- END_TF_DOCS -->