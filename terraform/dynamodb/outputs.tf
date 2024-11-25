#===================================================================
# DynamoDB Outputs
#===================================================================
output "table_name" {
  value = aws_dynamodb_table.iot_data.name
}

output "table_arn" {
  value = aws_dynamodb_table.iot_data.arn
}

output "devices_table_name" {
  value = aws_dynamodb_table.devices.name
}

output "devices_table_arn" {
  value = aws_dynamodb_table.devices.arn
}