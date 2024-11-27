#===================================================================
# API Gateway Outputs
#===================================================================
output "api_gateway_url" {
  value       = "${aws_api_gateway_rest_api.iot_api.execution_arn}/${aws_api_gateway_stage.iot_api_stage.stage_name}"
  description = "The URL of the API Gateway stage"
}