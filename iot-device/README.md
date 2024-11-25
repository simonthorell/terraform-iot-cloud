# AWS IoT-Core Instruction

### Add device to devices tables

Update device status using **Device Shadow**.
Announce status on topic `$aws/things/<DEVICE-ID>/shadow/update`:

```shell
{
  "state": {
    "reported": {
      "device_id": "<DEVICE-ID>",
      "owner": "<OWNER-NAME>",
      "status": "active" # or passive
    }
  }
}
```

**Links:**

- [AWS Docs](https://docs.aws.amazon.com/iot/latest/developerguide/device-shadow-mqtt.html?icmpid=docs_iot_hp_manage_things)

### Post IoT Data

These instructions can also be followed using f.e. [MQTT Explorer](https://mqtt-explorer.com/) to simulate an IoT-Device.

1. Get the Terraform generated MQTT URI from `./certs/iot_endpoint.txt`
2. Set port to `8883` (Secure TLS over TCP)
3. Use the Terraform generated certificates in `./certs`

- `root_ca.pem` **_(SERVER CERTIFICATE CA)_**
- `iot_cert.pem` **_(CLIENT CERTIFICATE)_**
- `iot_private_key.pem` **_(CLIENT KEY)_**

4. Post IoT Data to topic `iot/data/<DEVICE-ID>`:

```shell
# Example
{
  device_id: 123,
  temperature: 23,
  humidity: 14
}
```
