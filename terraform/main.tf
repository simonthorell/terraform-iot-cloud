# AWS General Setup
provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = var.aws_region
}


# AWS modules for iot-core, dynamodb, and amplify
module "iot_core" {
  source      = "./iot-core"
  thing_name  = var.iot_thing_name
}

# Resources
resource "aws_iot_certificate" "example_cert" {
  active = true
}