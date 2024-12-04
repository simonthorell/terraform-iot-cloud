# IoT Terraform AWS Cloud

This IoT system is designed to collect, process, store, and display temperature and humidity data from an ESP32 IoT device, integrating seamlessly with AWS cloud services and a frontend application.

### Production Environment

In the production environment, the ESP32 IoT device serves as the data source, collecting temperature and humidity readings and sending them to AWS IoT Core via MQTT. Once the data reaches IoT Core, a timestamp is added, ensuring each data point is precisely recorded. IoT Core then routes this enriched data using IoT Core Rules to AWS DynamoDB, where it is stored for further processing and retrieval.

AWS DynamoDB acts as the system's primary database, holding all the temperature, humidity, and timestamped records. The system's processing logic is handled by AWS Lambda functions. One function, iot_data, retrieves and processes the stored data for external applications and the frontend, while the devices function manages logic specific to the IoT devices themselves. These functions are exposed through AWS API Gateway, providing a structured REST API for accessing the data from external systems or the frontend.

To manage the application interface and user authentication, AWS Amplify serves as the bridge between the backend and the user-facing frontend. Amplify integrates seamlessly with AWS Cognito, which handles user authentication and access control, ensuring secure interactions with the system. Additionally, IAM manages permissions for all AWS resources, maintaining a secure and scalable architecture.

### Development Environment

In the development environment, the workflow begins with developers working on three main components. The first is the IoT device firmware, written in Rust, which is responsible for collecting and transmitting data. The second is the backend API, developed in Go, which powers the Lambda functions that process and retrieve data. The third component is the frontend, built using Nuxt.js and Vue, which displays the data in user-friendly diagrams and visualizations. These components are supported by a robust infrastructure setup, managed with Terraform to provision and configure the necessary AWS resources.

To streamline development, all artifacts—such as the Rust firmware, Go binaries, and frontend assets—are packaged and stored in dedicated S3 buckets. These buckets ensure that the components are easily accessible and can be deployed efficiently. The frontend, hosted via Amplify, consumes the processed IoT data through the API Gateway, offering users real-time insights into the temperature and humidity data collected from the IoT devices.

This system is a tightly integrated solution where data flows seamlessly from the IoT devices through the AWS cloud and is ultimately presented in intuitive dashboards and diagrams, offering users a complete and interactive view of their data.

## System Architechture Diagram

![My Image](.assets/diagram.png)

## Development Prerequisites

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
2. **[Golang](https://marketplace.visualstudio.com/items?itemName=golang.Go)**
3. **[Rust Analyzer](https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer)**
4. **[Prettier - Code Formatter](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)**
5. **[ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)**
6. **[Tailwind CSS IntelliSense](https://marketplace.visualstudio.com/items?itemName=bradlc.vscode-tailwindcss)**
7. **[Even Better TOML](https://marketplace.visualstudio.com/items?itemName=tamasfe.even-better-toml)**

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
AWS_ACCOUNT_ID=your-account-id               # Replace!
AWS_DEFAULT_REGION=aws-default-region        # Replace!
AWS_ACCESS_KEY_ID=your-access-key-id         # Replace!
AWS_SECRET_ACCESS_KEY=your-secret-access-key # Replace!

# IoT Device Configuration
THING_NAME=your-iot-device-name # Replace!
WIFI_SSID=your-wifi-ssid         # Replace!
WIFI_PASSWORD=your-wifi-password # Replace!
MQTT_PORT=8883
MQTT_PUB_TOPIC=/telemetry
MQTT_SUB_TOPIC=/downlink
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

## Terraform Output Files

Terraform generates several output files that are used for various tasks.

### Generated Files

```shell
# root directory
.amplify_app_url.txt

# api/.certs
iot_cert.pem
iot_endpoint.txt
iot_private_key.pem
root_ca.pem

# frontend/.config
api-endpoints.json
cognito-config.json
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
