#===================================================================
# API Gateway Variables
#===================================================================
variable "devices_function_arn" {
  description = "The ARN of the Lambda function to integrate with API Gateway"
  type        = string
}

variable "aws_region" {
  type        = string
  description = "The AWS region"
}