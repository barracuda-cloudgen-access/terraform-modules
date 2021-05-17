#
# AWS
#

variable "aws_profile" {
  description = "AWS profile"
  type        = string
  default     = "default"
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "s3_bucket_name" {
  description = "Name of the bucket to be used for the event logs."
  type        = string
  default     = "bucket.lambda.siem"
}

variable "lambda_role_name" {
  description = "Name of the lambda role."
  type        = string
  default     = "iam_for_lambda"
}

variable "access_s3_policy_name" {
  description = "Name of the policy for accessing s3 bucket."
  type        = string
  default     = "accesss3policy"
}

variable "lambda_name" {
  description = "Name of the public lambda endpoint to receive the event logs."
  type        = string
  default     = "s3siem_lambda"
}

variable "api_gateway_name" {
  description = "Name of the API gateway that publishes the lambda"
  type        = string
  default     = "s3siem_api"
}

variable "api_gateway_resource_path" {
  description = "Path for aws api gateway resource"
  type        = string
  default     = "siem"
}

variable "aws_api_gateway_stage" {
  description = "Stage for the api gateway deployment"
  type        = string
  default     = "prod"
}

variable "cluster_location" {
  description = "Cluster location (US, EU)"
  type        = string
  default     = "US"
}

# TODO change this
variable "ingress_domain_zone" {
  description = "Ingress domain zone"
  type        = string
  default     = "mgmt-console.dev.tech.fyde.com"
}

variable "ingress_domain_name" {
  description = "Ingress domain name"
  type        = string
  default     = "s3siem.mgmt-console.dev.tech.fyde.com"
}
