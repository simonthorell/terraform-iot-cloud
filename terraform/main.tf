provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = var.aws_region
}

# Include AWS modules for iot-core, dynamodb, and amplify

# module "iot-core" {
#   source = "./iot-core"
# }

# module "dynamodb" {
#  source = "./dynamodb"
# }

# module "amplify" {
#  source = "./amplify"
# }