# IoT Terraform AWS Cloud

## Prerequisites

### Required Applications

To set up and develop this project, you’ll need the following applications:

1. **[Git](https://git-scm.com/downloads)**
2. **[Docker Desktop](https://www.docker.com/products/docker-desktop/)**

### Optional Applications

These tools can enhance your development experience but are not strictly required:

1. **[Visual Studio Code (VS Code)](https://code.visualstudio.com/)**

2. **[Node.js](https://nodejs.org/)**

3. **[npm](https://docs.npmjs.com/downloading-and-installing-node-js-and-npm)**

4. **[Vue Devtools](https://devtools.vuejs.org/guide/installation.html)**

### Recommended VS Code Extensions

If you use VS Code as your IDE, the following extensions are recommended to improve your workflow:

1. **[Terraform](https://marketplace.visualstudio.com/items?itemName=hashicorp.terraform)**

2. **[Go](https://marketplace.visualstudio.com/items?itemName=golang.Go)**

3. **[Rust Analyzer](https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer)**

4. **[Prettier - Code Formatter](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)**

5. **[ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)**

6. **[Tailwind CSS IntelliSense](https://marketplace.visualstudio.com/items?itemName=bradlc.vscode-tailwindcss)**

## Setup AWS Account

1. Create [AWS](https://console.aws.amazon.com/) Account.
2. Go to [IAM Dashboard](https://console.aws.amazon.com/iam/) go to `Users`, click `Create user` and follow these steps:

   1. Specify **User name**
   2. Select **"Access key - Programmatic access"**.  
      Select **"Attach existing policies directly"**.  
      Select **"AdministratorAccess"** _(optionally, select each individual AWS service required)_.
   3. Review & Create **IAM User**.

3. Click your user in the IAM Dashboard and follow click `create access key`:

   1. Select **"Local code"**.
   2. Set tag such as _"Terraform access key for IoT project"_ f.e.
   3. Complete the setup and store both **Access Key** and **Secret Access Key** in a secure location.

4. Create a `.env` file in repository root and add the following variables:

```shell
# AWS Credentials
AWS_ACCOUNT_ID=your-account-id
AWS_DEFAULT_REGION=aws-default-region
AWS_ACCESS_KEY_ID=your-access-key-id
AWS_SECRET_ACCESS_KEY=your-secret-access-key
```

5. Go to the [Billing and Cost Management dashboard](https://console.aws.amazon.com/costmanagement/), and follow these steps:

   1. Go to **Budgets** and select `Create a budget`.
   2. Select either "Zero-Spend" (for testing with free-tier), or set a monthly spend limit.
   3. Enter the email address you want to get auto-alerts sent to.
   4. Create the Budget.

6. Test Access with **Terraform**:

Run the following commands to ensure Terraform can access AWS and configure resources based on the .env file.

```shell
docker-compose up --build terraform
```

## Development Environment

This repository comes with a preconfigured docker-compose file that contains all the necessary images for local development.

```shell
docker-compose up
```

## Deployment

This repositary contain scripts for automatic deployment of the cloud services.

The IoT device binary firmware will automatically we pushed to an AWS S3 bucket that the device can poll to get latest firmware using OTA (over the air).

## Licence

As per licence file.
