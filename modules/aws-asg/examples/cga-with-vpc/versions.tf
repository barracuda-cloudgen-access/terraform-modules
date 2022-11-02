terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.50"
    }
  }
  required_version = ">= 0.14"
}
