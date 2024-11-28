#===================================================================
# API Gateway Setup
#===================================================================
resource "aws_api_gateway_rest_api" "iot_api" {
  name        = "IoT API"
  description = "API Gateway for IoT devices"
}

#===================================================================
# API Gateway 'GetDevices' Endpoint
#===================================================================
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
  authorization = "NONE" # TODO: Update IAM
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

#===================================================================
# API Gateway 'GetIotData' Endpoint
#===================================================================
# Create a resource for the "iot-data" path
resource "aws_api_gateway_resource" "iot_data_resource" {
  rest_api_id = aws_api_gateway_rest_api.iot_api.id
  parent_id   = aws_api_gateway_rest_api.iot_api.root_resource_id
  path_part   = "iot-data"
}

# Create a GET method for the "iot-data" resource
resource "aws_api_gateway_method" "get_iot_data_method" {
  rest_api_id   = aws_api_gateway_rest_api.iot_api.id
  resource_id   = aws_api_gateway_resource.iot_data_resource.id
  http_method   = "GET"
  authorization = "NONE" # TODO: Update IAM
}

# Setup the integration between the API Gateway and the GetDeviceData Lambda function
resource "aws_api_gateway_integration" "iot_data_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.iot_api.id
  resource_id             = aws_api_gateway_resource.iot_data_resource.id
  http_method             = aws_api_gateway_method.get_iot_data_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.iot_data_function_arn}/invocations"
}

# Grant API Gateway Permissions to the GetDeviceData Lambda function
resource "aws_lambda_permission" "iot_data_api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvokeDeviceData"
  action        = "lambda:InvokeFunction"
  function_name = var.iot_data_function_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.iot_api.execution_arn}/*/*"
}

#===================================================================
# Deploy the API's
#===================================================================
# Deploy the API Gateway
resource "aws_api_gateway_deployment" "iot_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.iot_api.id

  # Add dependencies for all methods
  depends_on = [
    aws_api_gateway_method.get_devices_method,
    aws_api_gateway_method.get_iot_data_method
  ]
}

# Define the API Gateway stage
resource "aws_api_gateway_stage" "iot_api_stage" {
  deployment_id = aws_api_gateway_deployment.iot_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.iot_api.id
  stage_name    = "dev" # Alternative "prod", "staging", etc.
}

#===================================================================
# Output the API Gateway URLs to a file
#===================================================================
# Output the API Gateway URLs to a file
resource "local_file" "api_endpoints" {
  filename = "${path.root}/../certs/api-endpoints.json"
  content  = jsonencode({
    GetDevices     = "https://${aws_api_gateway_rest_api.iot_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.iot_api_stage.stage_name}/devices",
    GetIotData     = "https://${aws_api_gateway_rest_api.iot_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.iot_api_stage.stage_name}/iot-data"
  })
}