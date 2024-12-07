#===================================================================
# Lambda Variables
#===================================================================
variable "dynamodb_table_names" {
  description = "List of DynamoDB table names"
  type        = list(string)
}

variable "lambda_role_arn" {
  type        = string
  description = "IAM Role ARN for Lambda"
}

variable "discord_webhook_url" {
  type        = string
  description = "Discord Webhook URL"
}