#!/bin/sh

# Install dependencies using npm
npm install

# Generate the static Nuxt3 app build
npm run generate

# Create the dist folder if it doesn't exist
mkdir -p /app/dist

# Zip the build output
cd /app/.output/public
zip -r /app/dist/nuxt3-csr-build.zip .
