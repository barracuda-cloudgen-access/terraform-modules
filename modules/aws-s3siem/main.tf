provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

# create s3 bucket
# tfsec:ignore:AWS002 tfsec:ignore:AWS017
resource "aws_s3_bucket" "bucket" {
  bucket = var.s3_bucket_name
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.bucket.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = false
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
}

