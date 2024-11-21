#===================================================================
# S3 Variables
#===================================================================
variable "amplify_role_arn" {
  description = "The ARN of the IAM role for Amplify to access the S3 bucket"
  type        = string
}

variable "environment" {
  description = "The environment for the S3 bucket and build artifacts"
  type        = string
  default     = "Production"
}
