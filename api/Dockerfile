# Stage 1: Builder - Build Go Lambdas
FROM golang:1.23.1 as builder

# Set the working directory
WORKDIR /app

# Copy all Lambda directories into the build context
COPY api/lambdas/ ./lambdas/

# Loop over each Lambda directory and build the binaries
RUN for lambda_dir in ./lambdas/*/; do \
    echo "Building Lambda in $lambda_dir" && \
    cd $lambda_dir && \
    go mod tidy && \
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o /app/$(basename $lambda_dir) && \
    cd /app; \
    done

# Stage 2: Create lightweight container with zipped binaries
FROM alpine:latest
WORKDIR /app
RUN apk add --no-cache zip

# Copy Lambda binaries (only files) explicitly
COPY --from=builder /app/ /app/

# Ensure proper permissions
RUN chmod +x /app/*

# Create zip files for each Lambda binary and name bin as "bootstrap"
RUN mkdir -p /app/dist && \
    for lambda_binary in $(find /app -maxdepth 1 -type f -executable); do \
    echo "Zipping $lambda_binary with binary renamed to bootstrap" && \
    cp ${lambda_binary} /app/bootstrap && \
    zip -j /app/dist/$(basename ${lambda_binary}).zip /app/bootstrap && \
    rm /app/bootstrap; \
    done

# Output the zip files to a mounted volume
CMD ["sh", "-c", "cp -r /app/dist/* /dist && ls -l /dist"]
