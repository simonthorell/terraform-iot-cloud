#===================================================================
# Cognito Configuration
#===================================================================
resource "aws_cognito_user_pool" "user_pool" {
  name = "iot_user_pool"

  # Password policy configuration
  password_policy {
    minimum_length    = 8
    require_uppercase = true
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
  }

  # Admin user creation settings (optional)
  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  # Automatically verify email addresses by sending a verification code
  auto_verified_attributes = ["email"] 

  # Optional email configuration
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name                      = "my_user_pool_client"
  user_pool_id              = aws_cognito_user_pool.user_pool.id
  generate_secret           = false
  allowed_oauth_flows       = ["code", "implicit"]
  allowed_oauth_scopes      = ["email", "openid", "aws.cognito.signin.user.admin"]
  allowed_oauth_flows_user_pool_client = true

  # Add localhost for local development
  callback_urls = [
    "http://localhost:3000/",   # Localhost for development
    # "https://your-app-url.com/callback" # Production URL
  ]

  logout_urls = [
    "http://localhost:3000/logout",    # Localhost for development
    # "https://your-app-url.com/logout"  # Production URL
  ]

  supported_identity_providers = ["COGNITO"]
}

resource "local_file" "cognito_frontend_config" {
  filename = "${path.root}/../frontend/.config/cognito-config.json"
  content  = jsonencode({
    region            = var.aws_region
    userPoolId        = aws_cognito_user_pool.user_pool.id
    userPoolClientId  = aws_cognito_user_pool_client.user_pool_client.id
    authDomain        = replace(aws_cognito_user_pool.user_pool.endpoint, "https://", "")
    callbackUrl       = "http://localhost:3000/callback"
    logoutUrl         = "http://localhost:3000/logout"
  })
}
