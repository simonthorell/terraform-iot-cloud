#===================================================================
# AWS General Outputs
#===================================================================
output "iot_data_lambda_function_arn" {
  value = module.lambda.lambda_function_arn
}