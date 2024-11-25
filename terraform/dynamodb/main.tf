#===================================================================
# DynamoDB Tables
#===================================================================
resource "aws_dynamodb_table" "iot_data" {
  name           = "iot_data"
  hash_key       = "device_id" # Primary key
  range_key      = "timestamp" # Sort key

  attribute {
    name = "device_id"
    type = "S" # String type
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  billing_mode = "PROVISIONED"

  # Specify provisioned read and write capacities
  read_capacity  = 5
  write_capacity = 5
}

resource "aws_dynamodb_table" "devices" {
  name           = "devices"
  hash_key       = "device_id" # Primary key
  range_key      = "owner"     # Sort key

  attribute {
    name = "device_id"
    type = "S" # String type
  }

  attribute {
    name = "owner"
    type = "S" # String type for required "owner" attribute
  }

  # Optional attribute
  # attribute {
  #   name = "status"
  #   type = "S" # String type for optional "status" attribute
  # }

  billing_mode = "PROVISIONED"

  read_capacity  = 5
  write_capacity = 5
}