# IoT Frontend

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

### Local Development

```shell
cd frontend
npm install
npm run dev # starts local dev server
```

### Build Static Production Site

Move to root workspace directory and run:

```shell
docker-compose up --build nuxt-frontend
```

Deploy to AWS using Terraform:

````shell


# Nuxt Minimal Starter (Official README)

Look at the [Nuxt documentation](https://nuxt.com/docs/getting-started/introduction) to learn more.

## Setup

Make sure to install dependencies:

```bash
# npm
npm install

# pnpm
pnpm install

# yarn
yarn install

# bun
bun install
````

## Development Server

Start the development server on `http://localhost:3000`:

```bash
# npm
npm run dev

# pnpm
pnpm dev

# yarn
yarn dev

# bun
bun run dev
```

## Production

Build the application for production:

```bash
# npm
npm run build

# pnpm
pnpm build

# yarn
yarn build

# bun
bun run build
```

Locally preview production build:

```bash
# npm
npm run preview

# pnpm
pnpm preview

# yarn
yarn preview

# bun
bun run preview
```

Check out the [deployment documentation](https://nuxt.com/docs/getting-started/deployment) for more information.
