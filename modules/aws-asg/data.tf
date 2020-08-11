#
# Data
#

data "aws_caller_identity" "current" {}

data "aws_subnet" "vpc_from_first_subnet" {
  id = var.nlb_subnets[0]
}
