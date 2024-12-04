# API (AWS Lambdas)

We are writing our lambdas using golang, and a docker-image to compile them. Terraform is handling the deployment into AWS.

### Compile and Zip existing GO-Lambdas

```shell
docker-compose up --build api
```

### Write New Lambda Code

1. Crate a new subfolder in the `lambdas` directory.
2. Create `main.go`, `go.sum` and `go.mod` files.
3. Write your code.
4. Compile using docker by running command from workspace root directory:

```sh
docker-compose up --build api
```

5. The compiled binary will automatically get zipped to the `dist` directory.
6. Setup the new AWS lambda in `terraform` with correct policies etc.
7. Run terraform docker container configure AWS and push the zipped binary:

```sh
docker-compose up --build terraform

# Open a new terminal
docker exec -it terraform /bin/bash
terraform taint module.lambda.aws_lambda_function.devices_lambda
# Example 2: terraform taint module.lambda.aws_lambda_function.iot_data_lambda
terraform apply
```
