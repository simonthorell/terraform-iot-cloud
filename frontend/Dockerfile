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

# Build the application for production
RUN npm run build && npm run generate