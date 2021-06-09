terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.38"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2"
    }
  }
  required_version = ">= 0.14"
}
