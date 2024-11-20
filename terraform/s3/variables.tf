#===================================================================
# S3 Variables
#===================================================================
variable "environment" {
  description = "The environment for the S3 bucket and build artifacts"
  type        = string
  default     = "Production"
}