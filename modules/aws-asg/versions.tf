terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.23"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3"
    }
  }
  required_version = ">= 0.14"
}
