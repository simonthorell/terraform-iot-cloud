#===================================================================
# AWS General Variables
#===================================================================
variable "aws_account_id" {
  description = "The AWS account ID"
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "aws_access_key_id" {
  description = "The AWS Access Key ID"
  type        = string
}

variable "aws_secret_access_key" {
  description = "The AWS Secret Access Key"
  type        = string
}

variable "iot_thing_name" {
  description = "The name of the IoT Thing"
  default     = "iot-device"
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)"
  type        = string
  default     = "production"
}