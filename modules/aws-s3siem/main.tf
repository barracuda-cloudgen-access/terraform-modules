provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

# create s3 bucket
# tfsec:ignore:AWS002 tfsec:ignore:AWS017 tfsec:ignore:AWS077
resource "aws_s3_bucket" "bucket" {
  bucket = var.s3_bucket_name
  acl    = "private"

  # TODO remove before publishing
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# create policy for bucket
resource "aws_s3_bucket_policy" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject"
        ],
        Effect   = "Allow"
        Resource = "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}/*"
        Principal = {
          AWS = [
            "${aws_iam_role.iam_for_lambda.arn}"
          ]
        }
      }
    ]
  })
}

# create role for lambda
resource "aws_iam_role" "iam_for_lambda" {
  name = var.lambda_role_name

  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Principal = {
            Service = "lambda.amazonaws.com"
          }
          Effect = "Allow"
          Sid    = ""
        }
      ]
    }
  )
}

# create policies:
# - access s3 bucket
# - save logs to CloudWatch
resource "aws_iam_policy" "policy" {
  name        = var.access_s3_policy_name
  description = "access s3"
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "logs:PutLogEvents",
            "logs:CreateLogGroup",
            "logs:CreateLogStream"
          ],
          Resource = "arn:aws:logs:*:*:*"
        },
        {
          Effect = "Allow"
          Action = [
            "s3:PutObject"
          ]
          Resource = "arn:aws:s3:::${aws_s3_bucket.bucket.bucket}/*"
        }
      ]
  })
}

resource "aws_iam_role_policy_attachment" "lambdatos3policy" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.policy.arn
}

# create lambda
resource "aws_lambda_function" "lambda" {
  filename      = "files/lambda.zip"
  function_name = var.lambda_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  runtime = "nodejs14.x"

  depends_on = [
    aws_iam_role_policy_attachment.lambdatos3policy,
    aws_cloudwatch_log_group.lambda_logs,
  ]
}

# create logs for lambda

resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.lambda_name}"
  retention_in_days = 7
}


# create API gateway for publishing lambda

resource "aws_api_gateway_rest_api" "api" {
  name = var.api_gateway_name
}

resource "aws_api_gateway_resource" "resource" {
  path_part   = var.api_gateway_resource_path
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "method" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}

# set permissions for accessing lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.method.http_method}${aws_api_gateway_resource.resource.path}"
}

# create deployment for API
resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  depends_on = [
    aws_api_gateway_method.method,
    aws_api_gateway_integration.integration
  ]
  lifecycle {
    create_before_destroy = true
  }
}

# tfsec:ignore:AWS061
resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = var.aws_api_gateway_stage
}

locals {
  CA_URL = {
    US = "https://enterprise.fyde.com/.well-known/root-ca.pem",
    EU = "https://enterprise.eu.fyde.com/.well-known/root-ca.pem",
  }
}

data "http" "root_ca" {
  url = lookup(local.CA_URL, var.cluster_location)

  # unsupported, will issue warning but it's ok
  # request_headers = {
  #   Content-Type = "application/x-x509-ca-cert"
  # }
}

resource "local_file" "root_ca" {
  content  = data.http.root_ca.body
  filename = "${path.module}/files/root_ca.pem"
}

## Set up mTLS verification with root CA:
# aws apigateway create-domain-name --region us-east-2 \
#     --domain-name api.example.com \
#     --regional-certificate-arn arn:aws:acm:us-east-2:123456789012:certificate/123456789012-1234-1234-1234-12345678 \
#     --endpoint-configuration types=REGIONAL \
#     --security-policy TLS_1_2 \
#     --mutual-tls-authentication truststoreUri=s3://bucket-name/key-name

# upload cert to S3
# see https://docs.aws.amazon.com/apigateway/latest/developerguide/rest-api-mutual-tls.html
resource "aws_s3_bucket_object" "root_ca" {
  bucket = aws_s3_bucket.bucket.id
  key    = "certs/root_ca.pem"
  acl    = "private" # or can be "public-read"

  source = local_file.root_ca.filename
  etag   = sha256(local_file.root_ca.content)
}


# # Example DNS record creation using Route53.
# # Route53 is not specifically required; any DNS host can be used.
# resource "aws_route53_zone" "primary" {
#   name = var.ingress_domain_zone
# }

# resource "aws_route53_record" "record" {
#   name    = var.ingress_domain_name
#   type    = "A"
#   zone_id = aws_route53_zone.primary.id

#   alias {
#     evaluate_target_health = true
#     name                   = aws_api_gateway_domain_name.domain.regional_domain_name
#     zone_id                = aws_api_gateway_domain_name.domain.regional_zone_id
#   }
# }

# resource "aws_acm_certificate" "cert" {
#   domain_name       = aws_route53_record.record.name
#   validation_method = "DNS"
# }

# # create domain name
# resource "aws_api_gateway_domain_name" "domain" {
#   domain_name               = aws_acm_certificate.cert.domain_name
#   regional_certificate_name = aws_acm_certificate.cert.arn
#   security_policy           = "TLS_1_2"

#   mutual_tls_authentication {
#     truststore_uri = "s3://${aws_s3_bucket.bucket.id}/${aws_s3_bucket_object.root_ca.key}"
#   }

#   endpoint_configuration {
#     types = ["REGIONAL"]
#   }
# }

## TODO
## 1. Make sure all files are being sent correctly to lambda
## 2. make sure that lambda works with dependencies (nodejs14)
## 5. add alternative flow for terraform test not to fail ??
## 6. test end to end flow



# 2 workers
# 1 ingress - only validates json schema and sends to queue
# 2 ingress - validate certificate (do we need to sign the payload or can we use mTLS?)
# >>>> mTLS requires private key and certificate rotation management!!!! <<<<<