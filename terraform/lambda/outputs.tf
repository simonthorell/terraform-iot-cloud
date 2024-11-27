#===================================================================
# Lambda Outputs
#===================================================================
output "lambda_function_arn" {
  value = aws_lambda_function.iot_data_lambda.arn
}

output "devices_function_arn" {
  value       = aws_lambda_function.devices_lambda.arn
  description = "The ARN to invoke the Lambda function"
}