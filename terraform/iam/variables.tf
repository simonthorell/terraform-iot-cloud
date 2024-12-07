#===================================================================
# IAM Variables
#===================================================================
variable "dynamodb_table_arns" {
  description = "List of ARNs for the DynamoDB tables that the Lambda function can access"
  type        = list(string)
}

variable "iot_data_stream_arn" {
  description = "Stream ARN for the IoT data DynamoDB table"
  type        = string
}

variable "s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket for Amplify deployment artifacts"
}

variable "aws_account_id" {
  type        = string
  description = "The AWS account ID"
}

variable "aws_region" {
  type        = string
  description = "The AWS region"
}

variable "api_gateway_resources" {
  default = [
    "devices",
    "iot-data",
    "sensors"
  ]
}