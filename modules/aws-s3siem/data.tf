#
# Data
#

data "template_file" "lambda" {
  template = file("${path.module}/lambda/index.js")
  vars = {
    bucket = aws_s3_bucket.bucket.bucket
  }
}

data "archive_file" "lambda_zip" {
  type = "zip"
  source {
    content  = data.template_file.lambda.rendered
    filename = "index.js"
  }
  output_path = "${path.module}/files/lambda.zip"
}

data "aws_lambda_invocation" "test_example_event" {
  function_name = aws_lambda_function.lambda.function_name
  depends_on = [
    data.archive_file.lambda_zip
  ]
  input = <<JSON
{
  "bundle": {
    "device": {
      "id": "ebcdab58-6eb8-46fb-a193-d07a33e9eac8",
      "hostname": "a.b.c",
      "model": "mocked_model",
      "os": {
        "name": "mocked_name",
        "version": "mocked_version"
      }
    },
    "events": [
      {
        "creationDate": "2021-02-03T16:37:23+00:00",
        "id": "ebcdab58-6eb8-46fb-a190-d07a33e9eac8",
        "name": "tunnelState",
        "version": 1,
        "payload": "on"
      }
    ],
    "product": {
      "environment": "production",
      "id": "ebcdab58-6eb8-46fb-a190-d07a33e9eac8",
      "name": "app",
      "version": "1.1.1"
    },
    "state": {
      "version": 1,
      "payload": {
        "locale": "pt-pt",
        "screenLock": "notAvailable",
        "diskEncryption": "unknown",
        "antivirus": "disabled",
        "firewall": "outdated",
        "jailbroken": false,
        "user": {
          "email": "a@b.c"
        },
        "tenant": {
          "enrollmentId": "0de553f3-c956-48d5-ad13-240823a85044",
          "id": "0de553f3-c956-48d5-ad13-240823a85044"
        }
      }
    }
  },
  "errors": []
}
JSON
}
