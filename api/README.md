# API (AWS Lambdas)

Compile and zip Go-binaries:

```shell
docker-compose up --build api
```

## Create new binary for AWS Lambda

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
```
