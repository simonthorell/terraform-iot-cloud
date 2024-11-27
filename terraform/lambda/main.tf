#===================================================================
# IoT-Core Lambda Functions
#===================================================================
# Lambda Function (using Go compiled & zipped binary)
resource "aws_lambda_function" "iot_data_lambda" {
  filename         = "${path.root}/../api/dist/iot_data.zip"
  function_name    = "GetDeviceData"
  role             = var.lambda_role_arn
  handler          = "main"
  runtime          = "provided.al2"
  timeout          = 10
  memory_size      = 128

  environment {
    variables = {
      TABLE_NAME = "iot_data"
    }
  }
}

# Lambda Function to get devices from DynamoDB
resource "aws_lambda_function" "devices_lambda" {
  filename         = "${path.root}/../api/dist/devices.zip"
  function_name    = "GetDevices"
  role             = var.lambda_role_arn
  handler          = "main"
  runtime          = "provided.al2"
  timeout          = 10
  memory_size      = 128

  environment {
    variables = {
      TABLE_NAME = "devices"
    }
  }
}