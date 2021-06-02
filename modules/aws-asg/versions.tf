terraform {
  required_version = "~> 0.14"

  required_providers {
    aws      = "~> 3.26"
    template = "~> 2"
  }
}

provider "aws" {
  region = var.aws_region
}
