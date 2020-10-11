## Requirements

| Name | Version |
|------|---------|
| terraform | ~> 0.13 |
| aws | ~> 2 |
| template | ~> 2 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2 |
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| asg\_desired\_capacity | The number of Amazon EC2 instances that should be running in the auto scaling group | `number` | `3` | no |
| asg\_max\_size | The minimum size of the auto scaling group | `number` | `3` | no |
| asg\_min\_size | The maximum size of the auto scaling group | `number` | `3` | no |
| asg\_notification\_arn\_topic | Optional ARN topic to get Auto Scaling Group events | `string` | `""` | no |
| asg\_subnets | A list of subnet IDs to launch resources in. Use Private Subnets with NAT Gateway configured or Public Subnets | `list` | n/a | yes |
| aws\_region | AWS Region | `string` | n/a | yes |
| fyde\_access\_proxy\_public\_port | Public port for this proxy (must match the value configured in the console for this proxy) | `number` | `443` | no |
| fyde\_access\_proxy\_token | Fyde Access Proxy Token for this proxy (obtained from the console after proxy creation) | `any` | n/a | yes |
| launch\_cfg\_associate\_public\_ip\_address | Associate a public ip address with an instance in a VPC | `bool` | `false` | no |
| launch\_cfg\_instance\_type | The type of instance to use (t2.micro, t2.small, t2.medium, etc) | `string` | `"t2.small"` | no |
| launch\_cfg\_key\_pair\_name | The name of the key pair to use | `string` | n/a | yes |
| module\_version | Terraform module version | `string` | `"v1.0.0"` | no |
| nlb\_enable\_cross\_zone\_load\_balancing | Configure cross zone load balancing for the NLB | `bool` | `false` | no |
| nlb\_subnets | A list of public subnet IDs to attach to the LB. Use Public Subnets only | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| Network\_Load\_Balancer\_DNS\_Name | Update the Fyde Access Proxy in the Console with this DNS name |
| Security\_Group\_for\_Resources | Use this group to allow Fyde Access Proxy access to internal resources |
