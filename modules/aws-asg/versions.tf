terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.50"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3"
    }
  }
  required_version = ">= 0.14"
}
