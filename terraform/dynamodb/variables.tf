variable "table_name" {
  type        = string
  description = "Name of the DynamoDB table"
  default     = "iot_data"
}

variable "read_capacity" {
  type        = number
  description = "Read capacity for DynamoDB"
  default     = 5
}

variable "write_capacity" {
  type        = number
  description = "Write capacity for DynamoDB"
  default     = 5
}