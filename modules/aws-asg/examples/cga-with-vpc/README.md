<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.50 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.37.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudgen-access-proxy-ha"></a> [cloudgen-access-proxy-ha](#module\_cloudgen-access-proxy-ha) | ../../ | n/a |
| <a name="module_cloudgen-access-proxy-single"></a> [cloudgen-access-proxy-single](#module\_cloudgen-access-proxy-single) | ../../ | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | 3.18.1 |

## Resources

| Name | Type |
|------|------|
| [aws_default_route_table.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudgen_access_proxy_token"></a> [cloudgen\_access\_proxy\_token](#input\_cloudgen\_access\_proxy\_token) | Using the same token on both modules for test | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudgen-access-proxy-ha"></a> [cloudgen-access-proxy-ha](#output\_cloudgen-access-proxy-ha) | n/a |
| <a name="output_cloudgen-access-proxy-single"></a> [cloudgen-access-proxy-single](#output\_cloudgen-access-proxy-single) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
