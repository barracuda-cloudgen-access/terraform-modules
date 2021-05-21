## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 2 |
| <a name="requirement_template"></a> [template](#requirement\_template) | ~> 2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 2 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_notification.notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_notification) | resource |
| [aws_cloudwatch_log_group.fyde_access_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_elasticache_replication_group.redis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_replication_group) | resource |
| [aws_elasticache_subnet_group.redis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group) | resource |
| [aws_iam_instance_profile.profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.fyde_secrets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.redis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_launch_configuration.launch_config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_configuration) | resource |
| [aws_lb.nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.nlb_listener](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.nlb_target_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_secretsmanager_secret.token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.inbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.redis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.resources](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.redis](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [null_resource.redis_multiaz_enable](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.tags_as_list_of_maps](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_ami.fyde_access_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_subnet.vpc_from_first_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_asg_ami"></a> [asg\_ami](#input\_asg\_ami) | Defaults to 'fyde' to use the AMI maintained and secured by Fyde.<br>  Suported types are CentOS or AWS Linux based" | `string` | `"fyde"` | no |
| <a name="input_asg_desired_capacity"></a> [asg\_desired\_capacity](#input\_asg\_desired\_capacity) | The number of Amazon EC2 instances that should be running in the auto scaling group | `number` | `3` | no |
| <a name="input_asg_max_size"></a> [asg\_max\_size](#input\_asg\_max\_size) | The minimum size of the auto scaling group | `number` | `3` | no |
| <a name="input_asg_min_size"></a> [asg\_min\_size](#input\_asg\_min\_size) | The maximum size of the auto scaling group | `number` | `3` | no |
| <a name="input_asg_notification_arn_topic"></a> [asg\_notification\_arn\_topic](#input\_asg\_notification\_arn\_topic) | Optional ARN topic to get Auto Scaling Group events | `string` | `""` | no |
| <a name="input_asg_subnets"></a> [asg\_subnets](#input\_asg\_subnets) | A list of subnet IDs to launch resources in.<br>  Use Private Subnets with NAT Gateway configured or Public Subnets | `list(any)` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_cloudWatch_logs_retention_in_days"></a> [cloudWatch\_logs\_retention\_in\_days](#input\_cloudWatch\_logs\_retention\_in\_days) | Days to keep CloudWatch logs (Possible values are:<br>    1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0.<br>    0 = never delete.) | `number` | `7` | no |
| <a name="input_cloudwatch_logs_enabled"></a> [cloudwatch\_logs\_enabled](#input\_cloudwatch\_logs\_enabled) | Set to true to send '/var/log/message' logs to CloudWatch | `bool` | `true` | no |
| <a name="input_fyde_access_proxy_public_port"></a> [fyde\_access\_proxy\_public\_port](#input\_fyde\_access\_proxy\_public\_port) | Public port for this proxy (must match the value configured in the console for this proxy) | `number` | `443` | no |
| <a name="input_fyde_access_proxy_token"></a> [fyde\_access\_proxy\_token](#input\_fyde\_access\_proxy\_token) | Fyde Access Proxy Token for this proxy (obtained from the console after proxy creation) | `any` | n/a | yes |
| <a name="input_fyde_proxy_level"></a> [fyde\_proxy\_level](#input\_fyde\_proxy\_level) | Set the Fyde Proxy orchestrator log level | `string` | `"info"` | no |
| <a name="input_launch_cfg_associate_public_ip_address"></a> [launch\_cfg\_associate\_public\_ip\_address](#input\_launch\_cfg\_associate\_public\_ip\_address) | Associate a public ip address with an instance in a VPC | `bool` | `false` | no |
| <a name="input_launch_cfg_instance_type"></a> [launch\_cfg\_instance\_type](#input\_launch\_cfg\_instance\_type) | The type of instance to use (t2.micro, t2.small, t2.medium, etc) | `string` | `"t2.small"` | no |
| <a name="input_launch_cfg_key_pair_name"></a> [launch\_cfg\_key\_pair\_name](#input\_launch\_cfg\_key\_pair\_name) | The name of the key pair to use | `string` | n/a | yes |
| <a name="input_module_version"></a> [module\_version](#input\_module\_version) | Terraform module version | `string` | `"v1.1.0"` | no |
| <a name="input_nlb_enable_cross_zone_load_balancing"></a> [nlb\_enable\_cross\_zone\_load\_balancing](#input\_nlb\_enable\_cross\_zone\_load\_balancing) | Configure cross zone load balancing for the NLB | `bool` | `false` | no |
| <a name="input_nlb_subnets"></a> [nlb\_subnets](#input\_nlb\_subnets) | A list of public subnet IDs to attach to the LB. Use Public Subnets only | `list(string)` | n/a | yes |
| <a name="input_redis_subnets"></a> [redis\_subnets](#input\_redis\_subnets) | A list of subnet IDs to to use for the redis instances.<br>  At least two subnets on different Availability Zones must be provided | `list(any)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_Network_Load_Balancer_DNS_Name"></a> [Network\_Load\_Balancer\_DNS\_Name](#output\_Network\_Load\_Balancer\_DNS\_Name) | Update the Fyde Access Proxy in the Console with this DNS name |
