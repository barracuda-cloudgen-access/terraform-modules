
#
# Fyde Access Proxy
#

variable "fyde_access_proxy_public_port" {
  description = "Public port for this proxy (must match the value configured in the console for this proxy)"
  type        = number
  default     = 443

  validation {
    condition = (
      var.fyde_access_proxy_public_port >= 1 &&
      var.fyde_access_proxy_public_port <= 65535
    )
    error_message = "Public port needs to be >= 1 and <= 65535."
  }
}

variable "fyde_access_proxy_token" {
  description = "Fyde Access Proxy Token for this proxy (obtained from the console after proxy creation)"

  validation {
    condition = can(
      regex("^https://.+[.]fyde[.]com/proxies.+proxy_auth_token.+$",
      var.fyde_access_proxy_token)
    )
    error_message = "Provided Fyde Access Proxy Token doesn't match the expected format."
  }
}

variable "fyde_proxy_level" {
  description = "Set the Fyde Proxy orchestrator log level"
  type        = string
  default     = "info"

  validation {
    condition     = can(regex("^(info|warning|error|critical|debug)$", var.fyde_proxy_level))
    error_message = "AllowedValues: info, warning, error, critical or debug."
  }
}

variable "module_version" {
  description = "Terraform module version"
  type        = string
  default     = "v1.1.0"
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
  Defaults to 'fyde' to use the AMI maintained and secured by Fyde.
  Suported types are CentOS or AWS Linux based"
  EOF
  type        = string
  default     = "fyde"

  validation {
    condition     = can(regex("^(fyde|ami-.+)$", var.asg_ami))
    error_message = "AllowedValues: fyde or AMI id starting with 'ami-'."
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

#
# Launch Configuration
#

variable "launch_cfg_associate_public_ip_address" {
  description = "Associate a public ip address with an instance in a VPC"
  type        = bool
  default     = false
}

variable "launch_cfg_instance_type" {
  description = "The type of instance to use (t2.micro, t2.small, t2.medium, etc)"
  type        = string
  default     = "t2.small"
}

variable "launch_cfg_key_pair_name" {
  description = "The name of the key pair to use"
  type        = string
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
