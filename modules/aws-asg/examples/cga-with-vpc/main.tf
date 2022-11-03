#
# Variables
#

# Using the same token on both modules for test
variable "cloudgen_access_proxy_token" {
  type      = string
  sensitive = true
}

locals {
  application            = "cloudgen-access-proxy-test"
  aws_availability_zones = ["a", "b", "c"]
  aws_region             = "us-east-1"
  aws_subnet_cidr_block  = "172.16.0.0/23"
}

provider "aws" {
  region = local.aws_region
  default_tags {
    tags = {
      Owner       = "team"
      Environment = "test"
    }
  }
}

#
# CloudGen Access Proxy
#

module "cloudgen-access-proxy-single" {
  source = "../../"

  # More examples
  # run 'rm -rf .terraform/' after changing source
  # source = "git::git@github.com:barracuda-cloudgen-access/terraform-modules.git//modules/aws-asg?ref=vx.x.x"
  # source = "git::git@github.com:barracuda-cloudgen-access/terraform-modules.git//modules/aws-asg?ref=<branch-name>"
  # source = "../"

  # CloudGen Access Proxy
  cloudgen_access_proxy_public_port = 443
  cloudgen_access_proxy_token       = var.cloudgen_access_proxy_token

  # AWS
  aws_region = local.aws_region

  # Network Load Balancing
  nlb_subnets = module.vpc.public_subnets

  # Auto Scaling Group
  asg_desired_capacity = 1
  asg_min_size         = 1
  asg_max_size         = 1
  asg_subnets          = module.vpc.private_subnets

  # Launch Configuration
  launch_tmpl_instance_type = "t3.small"

  # AWS Systems Manager
  ssm_parameter_store = false

  tags = {
    extra_tag = "extra-value"
  }
}

output "cloudgen-access-proxy-single" {

  value = {
    Network_Load_Balancer_DNS_Name = module.cloudgen-access-proxy-single.Network_Load_Balancer_DNS_Name
    Security_Group_for_Resources   = module.cloudgen-access-proxy-single.Security_Group_for_Resources
  }
}


module "cloudgen-access-proxy-ha" {
  source = "../../"

  # More examples
  # run 'rm -rf .terraform/' after changing source
  # source = "git::git@github.com:barracuda-cloudgen-access/terraform-modules.git//modules/aws-asg?ref=vx.x.x"
  # source = "git::git@github.com:barracuda-cloudgen-access/terraform-modules.git//modules/aws-asg?ref=<branch-name>"
  # source = "../"

  # CloudGen Access Proxy
  cloudgen_access_proxy_public_port = 443
  cloudgen_access_proxy_token       = var.cloudgen_access_proxy_token

  # AWS
  aws_region = local.aws_region

  # Network Load Balancing
  nlb_subnets = module.vpc.public_subnets

  # Auto Scaling Group
  asg_desired_capacity = 3
  asg_min_size         = 3
  asg_max_size         = 3
  asg_subnets          = module.vpc.private_subnets

  # Launch Configuration
  launch_tmpl_instance_type = "t3.small"

  # AWS Systems Manager
  ssm_parameter_store = false

  tags = {
    extra_tag = "extra-value"
  }
}

output "cloudgen-access-proxy-ha" {

  value = {
    Network_Load_Balancer_DNS_Name = module.cloudgen-access-proxy-ha.Network_Load_Balancer_DNS_Name
    Security_Group_for_Resources   = module.cloudgen-access-proxy-ha.Security_Group_for_Resources
  }
}

#
# VPC
#

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.18.1"

  name = local.application

  cidr = local.aws_subnet_cidr_block

  azs = formatlist("${local.aws_region}%s", local.aws_availability_zones)

  private_subnets = [
    cidrsubnet(local.aws_subnet_cidr_block, 3, 0),
    cidrsubnet(local.aws_subnet_cidr_block, 3, 1),
    cidrsubnet(local.aws_subnet_cidr_block, 3, 2)
  ]

  private_subnet_tags = {
    Name = "${local.application}-private"
  }

  public_subnets = [
    cidrsubnet(local.aws_subnet_cidr_block, 3, 4),
    cidrsubnet(local.aws_subnet_cidr_block, 3, 5),
    cidrsubnet(local.aws_subnet_cidr_block, 3, 6)
  ]

  public_subnet_tags = {
    Name = "${local.application}-public"
  }

  enable_ipv6        = false
  enable_nat_gateway = true
  single_nat_gateway = true

  default_network_acl_name       = "${local.application}-default"
  default_security_group_egress  = []
  default_security_group_ingress = []
  default_security_group_name    = "${local.application}-default"
  manage_default_network_acl     = true
  manage_default_security_group  = true

  tags = {
    extra_tag = "extra-value"
  }

  vpc_tags = {
    Name = local.application
  }
}

resource "aws_default_route_table" "default" {
  default_route_table_id = module.vpc.default_route_table_id

  tags = {
    Name    = "${local.application}-default"
    warning = "This is created by AWS for the VPC and cannot be removed"
  }
}
