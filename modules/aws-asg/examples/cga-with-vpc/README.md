<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.24.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudgen-access-proxy"></a> [cloudgen-access-proxy](#module\_cloudgen-access-proxy) | ../../ | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 3.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_default_route_table.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudgen_access_proxy_token"></a> [cloudgen\_access\_proxy\_token](#input\_cloudgen\_access\_proxy\_token) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_Network_Load_Balancer_DNS_Name"></a> [Network\_Load\_Balancer\_DNS\_Name](#output\_Network\_Load\_Balancer\_DNS\_Name) | n/a |
| <a name="output_Security_Group_for_Resources"></a> [Security\_Group\_for\_Resources](#output\_Security\_Group\_for\_Resources) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
