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
        Resource = var.dynamodb_table_arns
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
          "dynamodb:Query",
          "dynamodb:Scan"
        ],
        "Effect": "Allow",
        "Resource": var.dynamodb_table_arns
      }
    ]
  })
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "lambda_role_policy_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
}

#===================================================================
# IAM Amplify Service Role & Policies
#===================================================================
# IAM Role for Amplify
resource "aws_iam_role" "amplify_service_role" {
  name = "amplify-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "amplify.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "amplify_s3_policy" {
  name   = "amplify-s3-access-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_name}",
          "arn:aws:s3:::${var.s3_bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "amplify_s3_policy_attachment" {
  role       = aws_iam_role.amplify_service_role.name
  policy_arn = aws_iam_policy.amplify_s3_policy.arn
}

#===================================================================
# IoT-Core Device Shadow Policy
#===================================================================
resource "aws_iam_policy" "iot_shadow_update_policy" {
  name = "iotShadowUpdatePolicy"

  policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": [
            "iot:UpdateThingShadow",
            "iot:GetThingShadow"
          ],
          "Effect": "Allow",
          "Resource": "arn:aws:iot:${var.aws_region}:${var.aws_account_id}:thing/*"
        }
      ]
    }
  POLICY
}

#===================================================================
# API Gateway Lambda Invoke Policy
#===================================================================
resource "aws_iam_policy" "api_gateway_access_policy" {
  name = "APIGatewayAccessPolicy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "execute-api:Invoke"
        ],
        Resource = "arn:aws:execute-api:eu-central-1:${var.aws_account_id}:*/*/*/devices"
      }
    ]
  })
}
