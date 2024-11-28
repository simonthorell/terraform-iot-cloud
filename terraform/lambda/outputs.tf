#===================================================================
# Lambda Outputs
#===================================================================
output "iot_data_function_arn" {
  value = aws_lambda_function.iot_data_lambda.arn
  description = "The ARN to invoke the IoT Data Lambda function"
}

output "devices_function_arn" {
  value       = aws_lambda_function.devices_lambda.arn
  description = "The ARN to invoke the Devices Lambda function"
}