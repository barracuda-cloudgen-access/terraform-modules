#
# Outputs
#

output "result_entry" {
  value = jsondecode(data.aws_lambda_invocation.test_example_event.result)
}
