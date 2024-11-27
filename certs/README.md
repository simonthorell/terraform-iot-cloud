# Certificates

## AWS IoT-Core Certificates

Terraform uses output.tf files to automatically generate certificates and store them in this folder.
When developing the IoT-device firmware, we can then get the certs from this directory.

We will also directly rely on these outputed files for our client side UI code.

## Content

```text
amplify_app_url.txt
cognito-config.json
iot_cert.pem
iot_endpoint.txt
iot_private_key.pem
root_ca.pem
```
