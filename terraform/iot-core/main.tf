#===================================================================
# IoT-Core Thing
#===================================================================
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

#===================================================================
# IoT-Core Thing Certificates
#===================================================================
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

#===================================================================
# IoT-Core Rules & Policies
#===================================================================
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

#===================================================================
# IoT-Core MQTT Setup
#===================================================================
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
      # table_name = var.dynamodb_table_name
      table_name = "iot_data"
    }
  }
}

#===================================================================
# IoT-Core Thing 'Device Shadow' Rules
#===================================================================
resource "aws_iot_topic_rule" "shadow_to_dynamodb" {
  name        = "shadowToDynamoDB"
  description = "Insert IoT device shadow updates into DynamoDB"
  enabled     = true

  sql_version = "2016-03-23"
  sql         = <<-SQL
    SELECT 
      state.reported.device_id AS device_id,
      state.reported.owner AS owner,
      state.reported.status AS status
    FROM 
      "$aws/things/+/shadow/update"
  SQL

  # DynamoDBv2 action to store the incoming data
  dynamodbv2 {
    role_arn   = var.iot_rule_dynamodb_role_arn

    put_item {
      table_name = "devices"
    }
  }
}