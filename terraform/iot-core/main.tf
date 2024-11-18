# Create the IoT Thing
resource "aws_iot_thing" "iot_thing" {
  name = var.thing_name
}

# Create an IoT Certificate
resource "aws_iot_certificate" "iot_cert" {
  active = true
}

# Attach the certificate to the IoT Thing
resource "aws_iot_thing_principal_attachment" "iot_attachment" {
  thing     = aws_iot_thing.iot_thing.name
  principal = aws_iot_certificate.iot_cert.arn
}

# Save the certificate PEM content to a local file
resource "local_file" "iot_cert_pem" {
  content  = aws_iot_certificate.iot_cert.certificate_pem
  filename = "${path.root}/../certs/iot_cert.pem"
}

# Save the private key PEM content to a local file
resource "local_file" "iot_private_key" {
  content  = aws_iot_certificate.iot_cert.private_key
  filename = "${path.root}/../certs/iot_private_key.pem"
}

# Download the AWS Root CA certificate using a local-exec provisioner
resource "null_resource" "download_root_ca" {
  provisioner "local-exec" {
    command = "curl -o ${path.root}/../certs/root_ca.pem https://www.amazontrust.com/repository/AmazonRootCA1.pem"
  }

  # Ensure this runs only when necessary (if the file doesn't exist)
  triggers = {
    root_ca_exists = fileexists("${path.root}/../certs/root_ca.pem") ? 1 : 0
  }
}
# Save the root CA certificate to a local file in the certs folder
resource "local_file" "iot_root_ca" {
  depends_on = [null_resource.download_root_ca]
  content    = file("${path.root}/../certs/root_ca.pem")
  filename   = "${path.root}/../certs/root_ca.pem"
}

# AWS IoT-Device Policy Setup
resource "aws_iot_policy" "device_policy" {
  name   = var.policy_name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iot:Connect",
          "iot:Publish",
          "iot:Receive",
          "iot:Subscribe",
          "iot:UpdateThingShadow",
          "iot:GetThingShadow"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach the policy to the IoT Certificate
resource "aws_iot_policy_attachment" "device_policy_attachment" {
  policy = aws_iot_policy.device_policy.name
  target = aws_iot_certificate.iot_cert.arn
}

# Retrieve the AWS IoT Core endpoint
data "aws_iot_endpoint" "iot_endpoint" {
  endpoint_type = "iot:Data-ATS"
}

# Output the IoT Core endpoint to a file for easy access
resource "local_file" "iot_endpoint_file" {
  content  = data.aws_iot_endpoint.iot_endpoint.endpoint_address
  filename = "${path.root}/../certs/iot_endpoint.txt"
}

output "iot_endpoint" {
  description = "The AWS IoT Core endpoint for MQTT connections"
  value       = data.aws_iot_endpoint.iot_endpoint.endpoint_address
}

# IoT Topic Rule to write incoming MQTT data to DynamoDB
# resource "aws_iot_topic_rule" "iot_data_to_dynamodb" {
#   name        = "iotDataToDynamoDB"
#   description = "Route IoT data directly to DynamoDB"

#   # Use IoT SQL to extract device_id from the topic and include all message payload data
#   sql = "SELECT *, topic(3) AS device_id FROM 'iot/data/+'"
#   sql_version = "2016-03-23"

#   # DynamoDB action to store the incoming data
#   dynamodb {
#     role_arn       = var.iot_rule_dynamodb_role_arn
#     table_name     = var.dynamodb_table_name
#     hash_key_field = "device_id"          # The hash key field in DynamoDB
#     hash_key_value = "device_id"       # Directly use the device_id alias from SQL
#     range_key_field = "timestamp"         # The range key field in DynamoDB
#     range_key_value = "timestamp()"       # Use the message's timestamp
#   }

#   # Enable the rule
#   # enabled = true
# }

resource "aws_iot_topic_rule" "iot_data_to_dynamodb" {
  name        = "iotDataToDynamoDB"
  description = "Route IoT data directly to DynamoDB"
  enabled     = true

  # SQL query to select all data and extract device_id from topic
  sql         = "SELECT * FROM '+/telemetry'"
  sql_version = "2016-03-23"

  # DynamoDBv2 action to store the incoming data
  dynamodbv2 {
    role_arn   = var.iot_rule_dynamodb_role_arn

    put_item {
      table_name = var.dynamodb_table_name
    }
  }
}

# Lambda Function (using Go compiled & zipped binary)
resource "aws_lambda_function" "iot_data_lambda" {
  filename         = "${path.root}/../api/dist/iot_data_lambda.zip"
  function_name    = "iotDataFunction"
  role             = var.lambda_role_arn
  handler          = "main"
  runtime          = "provided.al2"
  timeout          = 10
  memory_size      = 128

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name
    }
  }
}
