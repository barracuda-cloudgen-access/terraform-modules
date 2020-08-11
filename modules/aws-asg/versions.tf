terraform {
  required_version = "~> 0.12"

  required_providers {
    aws      = "~> 2"
    template = "~> 2"
  }
}

provider "aws" {
  region = var.aws_region
}
