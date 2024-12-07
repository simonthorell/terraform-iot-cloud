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

variable "iot_data_stream_arn" {
  description = "Stream ARN for the IoT data DynamoDB table"
  type        = string
}