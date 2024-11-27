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

To force re-upload new files, for example if re-compiling API code:

```shell
terraform taint module.lambda.aws_lambda_function.devices_lambda
terraform apply
```

You sometimes need to destroy old versions if a deploy fails:

```bash
terraform destroy -target=module.amplify
```

### Update Device Shadow State

Post to topic `$aws/things/iot-device/shadow/update`:

```mqtt
{
  "state": {
    "reported": {
      "connected": true
    }
  }
}
```

Link: [AWS Docs](https://docs.aws.amazon.com/iot/latest/developerguide/device-shadow-mqtt.html?icmpid=docs_iot_hp_manage_things)
