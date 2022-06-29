
#
# CloudGen Access Proxy
#

variable "cloudgen_access_proxy_public_port" {
  description = "Public port for this proxy (must match the value configured in the console for this proxy)"
  type        = number
  default     = 443

  validation {
    condition = (
      var.cloudgen_access_proxy_public_port >= 1 &&
      var.cloudgen_access_proxy_public_port <= 65535
    )
    error_message = "Public port needs to be >= 1 and <= 65535."
  }
}

variable "cloudgen_access_proxy_token" {
  description = "CloudGen Access Proxy Token for this proxy (obtained from the console after proxy creation)"
  type        = string
  sensitive   = true
  validation {
    condition = can(
      regex("^https:\\/\\/[a-zA-Z0-9.-]+\\.(fyde\\.com|access\\.barracuda\\.com)\\/proxies/v[0-9]+\\/enrollment\\/[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}\\?proxy_auth_token=[0-9a-zA-Z]+&tenant_id=[0-9a-fA-F]{8}-([0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$",
      var.cloudgen_access_proxy_token)
    )
    error_message = "Provided CloudGen Access Proxy Token doesn't match the expected format."
  }
}

variable "cloudgen_access_proxy_level" {
  description = "Set the CloudGen Access Proxy orchestrator log level"
  type        = string
  default     = "info"

  validation {
    condition     = can(regex("^(info|warning|error|critical|debug)$", var.cloudgen_access_proxy_level))
    error_message = "AllowedValues: info, warning, error, critical or debug."
  }
}

variable "module_version" {
  description = "Terraform module version"
  type        = string
  default     = "v2.0.1"
}

#
# AWS
#

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

#
# Network Load Balancing
#

variable "nlb_enable_cross_zone_load_balancing" {
  description = "Configure cross zone load balancing for the NLB"
  type        = bool
  default     = false
}

variable "nlb_subnets" {
  description = "A list of public subnet IDs to attach to the LB. Use Public Subnets only"
  type        = list(string)
}

#
# Auto Scaling Group
#

variable "asg_ami" {
  description = <<EOF
  Uses linux AMI maintained by AWS by default.
  Suported types are CentOS, Ubuntu or AWS Linux based.
  EOF
  type        = string
  default     = "amazonlinux2"

  validation {
    condition     = can(regex("^(amazonlinux2|ami-.+)$", var.asg_ami))
    error_message = "AllowedValues: amazonlinux2 or AMI id starting with 'ami-'."
  }
}

variable "asg_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the auto scaling group"
  type        = number
  default     = 3
}

variable "asg_min_size" {
  description = "The maximum size of the auto scaling group"
  type        = number
  default     = 3
}

variable "asg_max_size" {
  description = "The minimum size of the auto scaling group"
  type        = number
  default     = 3
}

variable "asg_subnets" {
  description = <<EOF
  A list of subnet IDs to launch resources in.
  Use Private Subnets with NAT Gateway configured or Public Subnets
  EOF
  type        = list(any)
}

variable "asg_notification_arn_topic" {
  description = "Optional ARN topic to get Auto Scaling Group events"
  type        = string
  default     = ""
}

variable "asg_health_check_grace_period" {
  description = <<EOF
  The amount of time, in seconds, that Amazon EC2 Auto Scaling waits
  before checking the health status of new instances.
  EOF
  type        = number
  default     = 300
}

#
# Launch Template
#

variable "launch_tmpl_associate_public_ip_address" {
  description = "Associate a public ip address with an instance in a VPC"
  type        = bool
  default     = false
}

variable "launch_tmpl_instance_type" {
  description = "The type of instance to use (e.g. t3.micro, t3.small, t3.medium, etc)"
  type        = string
  default     = "t3.small"
}

#
# AWS Systems Manager
#

variable "ssm_allow_console" {
  description = "Configures Systems Manager Session Manager to allow console"
  type        = bool
  default     = true
}

variable "ssm_parameter_store" {
  description = "Set to false to disable querying the Systems Manager Parameter Store for process arguments"
  type        = bool
  default     = true
}

#
# CloudWatch
#

variable "cloudwatch_logs_enabled" {
  description = "Set to true to send '/var/log/message' logs to CloudWatch"
  type        = bool
  default     = true
}

variable "cloudWatch_logs_retention_in_days" {
  description = <<EOF
    Days to keep CloudWatch logs (Possible values are:
    1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0.
    0 = never delete.)
  EOF
  type        = number
  default     = 7
}

#
# Redis
#

variable "redis_subnets" {
  description = <<EOF
  A list of subnet IDs to to use for the redis instances.
  At least two subnets on different Availability Zones must be provided
  EOF
  type        = list(any)
  default     = []
}

#
# Tags
#

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
