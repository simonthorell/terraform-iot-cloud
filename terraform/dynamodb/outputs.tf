#===================================================================
# DynamoDB Outputs
#===================================================================
output "table_names" {
  description = "Array of DynamoDB table names"
  value       = [
    aws_dynamodb_table.iot_data.name,
    aws_dynamodb_table.devices.name
  ]
}

output "table_arns" {
  description = "Array of DynamoDB table ARNs"
  value       = [
    aws_dynamodb_table.iot_data.arn,
    aws_dynamodb_table.devices.arn
  ]
}