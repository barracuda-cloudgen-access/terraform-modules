## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudgen-access-proxy"></a> [cloudgen-access-proxy](#module\_cloudgen-access-proxy) | git::git@github.com:barracuda-cloudgen-access/terraform-modules.git//modules/aws-asg | v1.2.2 |
| <a name="module_key_pair"></a> [key\_pair](#module\_key\_pair) | terraform-aws-modules/key-pair/aws | 1.0.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 3.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_default_route_table.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [tls_private_key.private_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudgen_access_proxy_token"></a> [cloudgen\_access\_proxy\_token](#input\_cloudgen\_access\_proxy\_token) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_Network_Load_Balancer_DNS_Name"></a> [Network\_Load\_Balancer\_DNS\_Name](#output\_Network\_Load\_Balancer\_DNS\_Name) | n/a |
