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
  source                     = "./iot-core"
  thing_name                 = var.iot_thing_name
  iot_rule_dynamodb_role_arn = module.iam.iot_rule_dynamodb_role_arn
}

module "dynamodb" {
  source = "./dynamodb"
}

module "iam" {
  source               = "./iam"
  aws_account_id       = var.aws_account_id 
  aws_region           = var.aws_region
  dynamodb_table_arns  = module.dynamodb.table_arns
  s3_bucket_name       = module.s3.bucket_name
}

module "lambda" {
  source               = "./lambda"
  dynamodb_table_names = module.dynamodb.table_names
  lambda_role_arn      = module.iam.lambda_role_arn
}

module "s3" {
  source               = "./s3"
  amplify_role_arn     = module.iam.amplify_service_role_arn
  environment          = var.environment
}

module "amplify" {
  source               = "./amplify"
  iam_service_role_arn = module.iam.amplify_service_role_arn
  s3_bucket_name       = module.s3.bucket_name
  s3_object_key        = module.s3.object_key
  environment          = var.environment
}

module "cognito" {
  source     = "./cognito"
  aws_region = var.aws_region
}

module "api_gateway" {
  source                     = "./api-gateway"
  devices_function_arn       = module.lambda.devices_function_arn
  iot_data_function_arn      = module.lambda.iot_data_function_arn
  aws_region                 = var.aws_region
}

#===================================================================
# Resources
#===================================================================
resource "aws_iot_certificate" "example_cert" {
  active = true
}