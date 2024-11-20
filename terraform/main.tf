#===================================================================
# AWS General Setup
#===================================================================
provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = var.aws_region
}

#===================================================================
# AWS modules
# Modules: IoT-Core, IAM, DynamoDB, Lambda, and Amplify
#===================================================================
module "iot_core" {
  source      = "./iot-core"
  thing_name  = var.iot_thing_name
  dynamodb_table_name = module.dynamodb.table_name
  lambda_role_arn     = module.iam.lambda_role_arn
  iot_rule_dynamodb_role_arn = module.iam.iot_rule_dynamodb_role_arn
}

module "dynamodb" {
  source = "./dynamodb"
}

module "iam" {
  source             = "./iam"
  dynamodb_table_arn = module.dynamodb.table_arn
}

module "s3" {
  source = "./s3"
}

#===================================================================
# Resources
#===================================================================
resource "aws_iot_certificate" "example_cert" {
  active = true
}