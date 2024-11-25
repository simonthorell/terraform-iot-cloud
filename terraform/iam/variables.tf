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

variable "aws_account_id" {
  type        = string
  description = "The AWS account ID"
}

variable "aws_region" {
  type        = string
  description = "The AWS region"
}