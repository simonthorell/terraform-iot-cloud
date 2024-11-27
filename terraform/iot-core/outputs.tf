#===================================================================
# IoT-Core Outputs
#===================================================================
output "certificate_arn" {
  description = "The ARN of the IoT Certificate"
  value       = aws_iot_certificate.iot_cert.arn
}

output "certificate_pem" {
  description = "The PEM-encoded certificate"
  value       = aws_iot_certificate.iot_cert.certificate_pem
}

output "private_key" {
  description = "The private key associated with the certificate"
  value       = aws_iot_certificate.iot_cert.private_key
}

output "certificate_id" {
  description = "The certificate ID"
  value       = aws_iot_certificate.iot_cert.id
}
