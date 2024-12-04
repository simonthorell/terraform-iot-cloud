#===================================================================
# Cognito Variables
#===================================================================
variable "aws_region" {
  type        = string
  description = "The AWS region"
}

variable "amplify_app_url" {
  type        = string
  description = "The default URL of the Amplify app"
}