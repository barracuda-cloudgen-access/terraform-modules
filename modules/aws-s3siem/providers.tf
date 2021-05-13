terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.1"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
    http = {
      source  = "hashicorp/http"
      version = "2.1.0"
    }
  }
  required_version = ">= 0.14"
}
