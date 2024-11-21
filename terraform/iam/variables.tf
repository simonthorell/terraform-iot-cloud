#===================================================================
# IAM Variables
#===================================================================
variable "dynamodb_table_arn" {
  type        = string
  description = "ARN of the DynamoDB table"
}

variable "s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket for Amplify deployment artifacts"
}
