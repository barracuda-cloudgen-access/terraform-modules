#
# Outputs
#

output "result_entry" {
  value = jsondecode(data.aws_lambda_invocation.test_example_event.result)
}

output "api_gateway_url" {
  # https://docs.aws.amazon.com/apigateway/latest/developerguide/how-to-call-api.html
  # https://{restapi_id}.execute-api.{region}.amazonaws.com/{stage_name}/
  # where {restapi_id} is the API identifier, {region} is the Region, and {stage_name} is the stage name of the API deployment. 
  # using default as stage
  value = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.aws_api_gateway_stage}/${var.api_gateway_resource_path}"
}

output "e2e_test" {
  value = <<COMMAND
      curl -X POST
           -H "Accept: application/json"
           -H "Content-type: application/json"
           --data-binary @./sample_event.json
           https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.aws_region}.amazonaws.com/${var.aws_api_gateway_stage}/${var.api_gateway_resource_path}"
    COMMAND
}
