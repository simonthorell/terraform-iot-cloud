# Use the official Go image to build the application
FROM golang:1.23.1 as builder

# Set the working directory
WORKDIR /app

# Copy the Go module files and download dependencies
COPY api/go.mod api/go.sum ./
RUN go mod download

# Copy the source code
COPY api/ .

# Build the Go binary for AWS Lambda (Linux/amd64) and name it "bootstrap"
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o bootstrap main.go

# Use a lightweight image to create the final zip file
FROM alpine:latest
WORKDIR /app
RUN apk add --no-cache zip
COPY --from=builder /app/bootstrap .

# Zip the Go binary as "bootstrap"
RUN mkdir -p /app/dist && zip /app/dist/iot_data_lambda.zip bootstrap

# Output the zip file to a mounted volume
CMD ["cp", "/app/dist/iot_data_lambda.zip", "/dist/iot_data_lambda.zip"]