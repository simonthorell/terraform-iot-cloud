#===================================================================
# Amplify Variables
#===================================================================
variable "s3_bucket_name" {
  description = "The S3 bucket name where the Nuxt build zip is stored"
  type        = string
}

variable "s3_object_key" {
  description = "The key for the Nuxt build zip file in the S3 bucket"
  type        = string
}

variable "iam_service_role_arn" {
  description = "The ARN of the IAM service role for Amplify"
  type        = string
}

variable "environment" {
  description = "Environment (e.g., dev, staging, production)"
  type        = string
}
