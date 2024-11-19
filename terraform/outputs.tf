#===================================================================
# AWS General Outputs
#===================================================================
output "iot_data_lambda_function_arn" {
  value = module.iot_core.lambda_function_arn
}