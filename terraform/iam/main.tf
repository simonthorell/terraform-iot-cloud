#===================================================================
# IAM IoT-Core to DynamoDB Roles and Policies
#===================================================================
resource "aws_iam_role" "iot_rule_dynamodb_role" {
  name = "IoTRuleDynamoDBRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "iot.amazonaws.com"
        }
      }
    ]
  })
}

# Let IoT Rule Access DynamoDB
resource "aws_iam_policy" "iot_dynamodb_policy" {
  name   = "IoTDynamoDBPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "dynamodb:PutItem"
        ],
        Effect   = "Allow",
        Resource = var.dynamodb_table_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_iot_dynamodb_policy" {
  role       = aws_iam_role.iot_rule_dynamodb_role.name
  policy_arn = aws_iam_policy.iot_dynamodb_policy.arn
}

#===================================================================
# IAM Lambda Rules & Policies
#===================================================================
# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "iot_data_lambda_role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy to Allow Lambda to Access DynamoDB
resource "aws_iam_policy" "lambda_dynamodb_policy" {
  name        = "LambdaDynamoDBPolicy"
  description = "Policy for Lambda to access DynamoDB"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "dynamodb:GetItem",
          "dynamodb:Query"
        ],
        "Effect": "Allow",
        "Resource": var.dynamodb_table_arn
      }
    ]
  })
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "lambda_role_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}
