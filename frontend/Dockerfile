# Base image with Node.js for multi-platform support
FROM node:18-alpine

# Set the working directory
WORKDIR /app

# Install zip utility
RUN apk add --no-cache zip

# Copy package.json and package-lock.json files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Copy the entrypoint script and make it executable
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Use shellscript to build & zip the frontend
ENTRYPOINT ["/app/entrypoint.sh"]
