resource "aws_dynamodb_table" "iot_data" {
  name           = "iot_data"
  hash_key       = "device_id"
  range_key      = "timestamp"

  attribute {
    name = "device_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  billing_mode = "PROVISIONED"

  # Specify provisioned read and write capacities
  read_capacity  = 5
  write_capacity = 5

  # Enable a DynamoDB stream to capture data changes
  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"
}