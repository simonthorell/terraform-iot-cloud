#===================================================================
# IAM Outputs
#===================================================================
output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}

output "iot_rule_dynamodb_role_arn" {
  value = aws_iam_role.iot_rule_dynamodb_role.arn
}

output "amplify_service_role_arn" {
  value = aws_iam_role.amplify_service_role.arn
}
