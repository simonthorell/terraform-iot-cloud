#===================================================================
# Lambda Outputs
#===================================================================
output "lambda_function_arn" {
  value = aws_lambda_function.iot_data_lambda.arn
}