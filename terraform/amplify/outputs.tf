#===================================================================
# Amplify Variables
#===================================================================
# Output the Amplify app URL
output "amplify_app_url" {
  description = "The default URL of the Amplify app"
  value       = aws_amplify_app.nuxt3_app.default_domain
}

output "webhook_url" {
  value = aws_amplify_webhook.deploy_hook.url
}