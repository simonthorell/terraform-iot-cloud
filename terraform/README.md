# Terraform

### Tips & Trix

If using VS-Code, install the [Terraform Extension](https://marketplace.visualstudio.com/items?itemName=4ops.terraform).

### Start Container Shell

Attached to shell of Docker Terraform container:

```shell
docker exec -it terraform /bin/bash
```

### Apply Configuration Updates to AWS

Apply all changes to AWS:

```bash
terraform apply -auto-approve
```

Apply changes to specific module:

```bash
# Example 1:
terraform apply -target=module.iot_core -auto-approve
# Example 2:
terraform apply -target=module.dynamodb -auto-approve
```

### Changing Files Require Terraform Taint

To force re-upload new files, for example if re-compiling API code, we need to taint the files.

```shell
# Lambda Compiled Zip
terraform taint module.lambda.aws_lambda_function.devices_lambda
terraform taint module.lambda.aws_lambda_function.iot_data_lambda

# Update Endpoint Json
terraform taint module.api_gateway.local_file.api_endpoints

# Frontend build Zip
terraform taint module.s3.aws_s3_object.build_zip
# Note! If we recompile API, we may also need to rebuild frontend!

# Frontend Resources
terraform taint module.api_gateway.local_file.api_endpoints
terraform taint module.cognito.local_file.cognito_frontend_config

# IoT-Device Resources
terraform taint module.iot_core.local_file.iot_cert_pem
terraform taint module.iot_core.local_file.iot_private_key
terraform taint module.iot_core.local_file.iot_root_ca
terraform taint module.iot_core.local_file.iot_endpoint_file

# General output
terraform taint module.amplify.local_file.amplify_url
```

After we taint - we must apply!

```shell
terraform apply
```

You also sometimes need to destroy old versions if a deploy fails:

```bash
terraform destroy -target=module.amplify
```
