#===================================================================
# IoT-Core Variables
#===================================================================
variable "thing_name" {
  description = "The name of the IoT Thing"
  type        = string
}

variable "policy_name" {
  description = "The name of the IoT Policy for the device"
  type        = string
  default     = "device_policy"
}

variable "iot_rule_dynamodb_role_arn" {
  type        = string
  description = "IAM role ARN for IoT rule to write to DynamoDB"
}