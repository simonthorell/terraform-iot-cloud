variable "thing_name" {
  description = "The name of the IoT Thing"
  type        = string
}

variable "policy_name" {
  description = "The name of the IoT Policy for the device"
  type        = string
  default     = "device_policy"
}