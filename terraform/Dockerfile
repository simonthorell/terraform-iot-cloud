# Use an official Terraform image
FROM hashicorp/terraform:latest

# Install dependencies
RUN apk add --no-cache bash curl jq

# Set the working directory
WORKDIR /workspace

# Copy files from the project into the container
COPY . .