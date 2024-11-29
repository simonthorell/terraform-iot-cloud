#===================================================================
# API Gateway Setup
#===================================================================
resource "aws_api_gateway_rest_api" "iot_api" {
  name        = "IoT API"
  description = "API Gateway for IoT devices"
}

#===================================================================
# API Gateway - Setup Instructions
#===================================================================
/**
 * Each endpoint in the API Gateway require an OPTION method to handle 
 * CORS preflight requests.
 * 
 * As we are relying on AWS_PROXY integration, we need to set up the
 * required CORS headers directly in our lambda source code response.
 * See example in: `api/lambdas/devices/main.go`
 */

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
  authorization = "NONE"
}

# Add method responses for GET to include CORS headers
resource "aws_api_gateway_method_response" "get_devices_response" {
  rest_api_id = aws_api_gateway_rest_api.iot_api.id
  resource_id = aws_api_gateway_resource.devices_resource.id
  http_method = aws_api_gateway_method.get_devices_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

# Integrate GET method with Lambda
resource "aws_api_gateway_integration" "get_devices_integration" {
  rest_api_id             = aws_api_gateway_rest_api.iot_api.id
  resource_id             = aws_api_gateway_resource.devices_resource.id
  http_method             = aws_api_gateway_method.get_devices_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.devices_function_arn}/invocations"
}

# Add an OPTIONS method to handle CORS preflight requests
resource "aws_api_gateway_method" "options_devices_method" {
  rest_api_id   = aws_api_gateway_rest_api.iot_api.id
  resource_id   = aws_api_gateway_resource.devices_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"

  request_parameters = {
    "method.request.header.Access-Control-Allow-Origin"  = true
    "method.request.header.Access-Control-Allow-Methods" = true
    "method.request.header.Access-Control-Allow-Headers" = true
  }
}

# Add CORS headers to the OPTIONS method response
resource "aws_api_gateway_method_response" "options_devices_response" {
  rest_api_id = aws_api_gateway_rest_api.iot_api.id
  resource_id = aws_api_gateway_resource.devices_resource.id
  http_method = aws_api_gateway_method.options_devices_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

# Set up the Integration for OPTIONS method
resource "aws_api_gateway_integration" "options_devices_integration" {
  rest_api_id       = aws_api_gateway_rest_api.iot_api.id
  resource_id       = aws_api_gateway_resource.devices_resource.id
  http_method       = aws_api_gateway_method.options_devices_method.http_method
  type              = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Set up the Integration Response for OPTIONS method
resource "aws_api_gateway_integration_response" "options_devices_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.iot_api.id
  resource_id = aws_api_gateway_resource.devices_resource.id
  http_method = aws_api_gateway_method.options_devices_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }

  depends_on = [
    aws_api_gateway_integration.options_devices_integration
  ]
}

# Allow permission for GET Devices to be invoked by API Gateway
resource "aws_lambda_permission" "get_devices_api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvokeGetDevices"
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
  authorization = "NONE"

  request_parameters = {
    "method.request.querystring.device_id" = true
  }
}

# Integrate GET method with Lambda
resource "aws_api_gateway_integration" "get_iot_data_integration" {
  rest_api_id             = aws_api_gateway_rest_api.iot_api.id
  resource_id             = aws_api_gateway_resource.iot_data_resource.id
  http_method             = aws_api_gateway_method.get_iot_data_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri = "arn:aws:apigateway:${var.aws_region}:lambda:path/2015-03-31/functions/${var.iot_data_function_arn}/invocations"

  request_parameters = {
    "integration.request.querystring.device_id" = "method.request.querystring.device_id"
  }
}

# Add method responses for GET to include CORS headers
resource "aws_api_gateway_method_response" "get_iot_data_response" {
  rest_api_id = aws_api_gateway_rest_api.iot_api.id
  resource_id = aws_api_gateway_resource.iot_data_resource.id
  http_method = aws_api_gateway_method.get_iot_data_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

# Add an OPTIONS method to handle CORS preflight requests
resource "aws_api_gateway_method" "options_iot_data_method" {
  rest_api_id   = aws_api_gateway_rest_api.iot_api.id
  resource_id   = aws_api_gateway_resource.iot_data_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"

  request_parameters = {
    "method.request.header.Access-Control-Allow-Origin"  = true
    "method.request.header.Access-Control-Allow-Methods" = true
    "method.request.header.Access-Control-Allow-Headers" = true
  }
}

# Add CORS headers to the OPTIONS method response
resource "aws_api_gateway_method_response" "options_iot_data_response" {
  rest_api_id = aws_api_gateway_rest_api.iot_api.id
  resource_id = aws_api_gateway_resource.iot_data_resource.id
  http_method = aws_api_gateway_method.options_iot_data_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Headers" = true
  }
}

# Set up the Integration for OPTIONS method
resource "aws_api_gateway_integration" "options_iot_data_integration" {
  rest_api_id       = aws_api_gateway_rest_api.iot_api.id
  resource_id       = aws_api_gateway_resource.iot_data_resource.id
  http_method       = aws_api_gateway_method.options_iot_data_method.http_method
  type              = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# Set up the Integration Response for OPTIONS method
resource "aws_api_gateway_integration_response" "options_iot_data_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.iot_api.id
  resource_id = aws_api_gateway_resource.iot_data_resource.id
  http_method = aws_api_gateway_method.options_iot_data_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
  }

  depends_on = [
    aws_api_gateway_integration.options_iot_data_integration
  ]
}

# Allow permission for GET IotData to be invoked by API Gateway
resource "aws_lambda_permission" "get_iot_data_api_gateway_permission" {
  statement_id  = "AllowAPIGatewayInvokeGetIotData"
  action        = "lambda:InvokeFunction"
  function_name = var.iot_data_function_arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.iot_api.execution_arn}/*/*"
}

#===================================================================
# Deploy the API Gateway
#===================================================================
resource "aws_api_gateway_deployment" "iot_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.iot_api.id

  depends_on = [
    # Devices API Endpoint
    aws_api_gateway_method.options_devices_method,
    aws_api_gateway_integration.options_devices_integration,
    aws_api_gateway_method.get_devices_method,
    aws_api_gateway_integration.get_devices_integration,

    # IotData API Endpoint
    aws_api_gateway_method.options_iot_data_method,
    aws_api_gateway_integration.options_iot_data_integration,
    aws_api_gateway_method.get_iot_data_method,
    aws_api_gateway_integration.get_iot_data_integration
  ]
}

# Define the API Gateway stage
resource "aws_api_gateway_stage" "iot_api_stage" {
  deployment_id = aws_api_gateway_deployment.iot_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.iot_api.id
  stage_name    = "prod"
}

#===================================================================
# Output the API Gateway URLs to a file
#===================================================================
resource "local_file" "api_endpoints" {
  filename = "${path.root}/../frontend/.config/api-endpoints.json"
  content  = jsonencode({
    GetDevices     = "https://${aws_api_gateway_rest_api.iot_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.iot_api_stage.stage_name}/devices",
    GetIotData     = "https://${aws_api_gateway_rest_api.iot_api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.iot_api_stage.stage_name}/iot-data"
  })
}
