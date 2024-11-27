#===================================================================
# API Gateway 'GetDevices' Endpoint
#===================================================================
resource "aws_api_gateway_rest_api" "iot_api" {
  name        = "IoT API"
  description = "API Gateway for IoT devices"
}

# Create a resource for the "devices" path
resource "aws_api_gateway_resource" "devices_resource" {
  rest_api_id = aws_api_gateway_rest_api.iot_api.id
  parent_id   = aws_api_gateway_rest_api.iot_api.root_resource_id
  path_part   = "devices"
}

# Create a GET method for the "devices" resource
resource "aws_api_gateway_method" "get_devices_method" {
  rest_api_id   = aws_api_gateway_rest_api.iot_api.id
  resource_id   = aws_api_gateway_resource.devices_resource.id
  http_method   = "GET"
  authorization = "NONE" # Can be updated to use IAM or other auth methods
}

# Setup the integration between the API Gateway and the Lambda function
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.iot_api.id
  resource_id             = aws_api_gateway_resource.devices_resource.id
  http_method             = aws_api_gateway_method.get_devices_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.devices_function_arn}/invocations"
}


# Grant API Gateway Permissions to Lambda
resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.devices_function_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.iot_api.execution_arn}/*/*"
}

# Deploy the API Gateway
resource "aws_api_gateway_deployment" "iot_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.iot_api.id

  # Add a dependency to ensure all methods are created before deploying
  depends_on = [aws_api_gateway_method.get_devices_method]
}

# Define the API Gateway stage
resource "aws_api_gateway_stage" "iot_api_stage" {
  deployment_id = aws_api_gateway_deployment.iot_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.iot_api.id
  stage_name    = "dev" # You can use "prod", "staging", etc.
}
#===================================================================
# Output the API Gateway URLs to a file
#===================================================================
resource "local_file" "api_endpoints" {
  filename = "${path.root}/../certs/api_endpoints.txt"
  content  = <<EOT
# API Gateway Endpoints

- Base URL: ${aws_api_gateway_rest_api.iot_api.execution_arn}/${aws_api_gateway_stage.iot_api_stage.stage_name}

Endpoints:
- GET /devices: ${aws_api_gateway_rest_api.iot_api.execution_arn}/${aws_api_gateway_stage.iot_api_stage.stage_name}/devices
EOT
}