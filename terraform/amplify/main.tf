#===================================================================
# Amplify Setup for Nuxt.js SPA
#===================================================================
resource "aws_amplify_app" "nuxt3_app" {
  name                = "nuxt3-app"
  platform            = "WEB"
  iam_service_role_arn = var.iam_service_role_arn

  environment_variables = {
    "NUXT_ENV" = var.environment
  }

  custom_rule {
    source = "/<*>"
    target = "/index.html"
    status = "200"
  }
}

resource "aws_amplify_branch" "main_branch" {
  app_id      = aws_amplify_app.nuxt3_app.id
  branch_name = "main"
}

resource "aws_amplify_webhook" "deploy_hook" {
  app_id      = aws_amplify_app.nuxt3_app.id # dynamic "app-id"
  branch_name = aws_amplify_branch.main_branch.branch_name # "main"
  description = "Deploy hook for Nuxt3 CSR app"
}

resource "null_resource" "trigger_amplify_deploy" {
  triggers = {
    deployment_time = timestamp() # Redeploy every time
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "Webhook URL: ${aws_amplify_webhook.deploy_hook.url}" && \
      echo "SourceURL: s3://${var.s3_bucket_name}/${var.s3_object_key}" && \
      curl -X POST "${aws_amplify_webhook.deploy_hook.url}" \
           -H "Content-Type: application/json" \
           -d '{"sourceUrl": "s3://${var.s3_bucket_name}/${var.s3_object_key}"}'
    EOT
  }
}