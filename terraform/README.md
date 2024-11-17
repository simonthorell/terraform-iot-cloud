# Terraform

### Tips & Trix

If using VS-Code, install the [Terraform Extension](https://marketplace.visualstudio.com/items?itemName=4ops.terraform).

### Start Container Shell

Attached to shell of Docker Terraform container:

```shell
docker-compose -it terraform /bin/bash
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
