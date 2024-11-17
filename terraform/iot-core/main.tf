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

# Save the Amazon root CA certificate to a local file
resource "local_file" "iot_root_ca" {
  content  = <<-EOT
    -----BEGIN CERTIFICATE-----
    [Place Amazon Root CA certificate here]
    -----END CERTIFICATE-----
  EOT
  filename = "${path.root}/../certs/root_ca.pem"
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
          "iot:Subscribe"
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