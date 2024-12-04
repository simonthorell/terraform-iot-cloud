# IoT Frontend

### Local Development

```shell
cd frontend
npm install
npm run dev # starts local dev server
```

## Build Frontend

```shell
cd $(git rev-parse --show-toplevel) # Root of repo
docker-compose up --build nuxt-frontend # Build static page
docker-compose up --build terraform # Start Terraform Container

# Open a new terminal
docker exec -it terraform /bin/bash # Open shell in container
terraform taint module.s3.aws_s3_object.build_zip # Delete old static build
terraform apply # Upload new static build
# Enter 'yes' when requested

# Due to Terraformlimitation in Amplify - login and manually
# select the .zip-file from the S3-bucket, and press 'deploy'.
```
