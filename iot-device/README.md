# AWS IoT-Core Instruction

### Add device to devices tables

Update device status using **Device Shadow**.
Announce status on topic `$aws/things/<DEVICE-ID>/shadow/update`:

```json
{
  "state": {
    "reported": {
      "device_id": "<DEVICE-ID>",
      "owner": "<OWNER-NAME>",
      "status": "active"
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

4. Post IoT Data to topic `<DEVICE-ID>/telemetry`:

_**TODO: Add timestamp in lambda?**_

```shell
{
  "device_id": "<DEVICE-ID>",
  "timestamp": 1693851730,
  "temperature": 23,
  "humidity": 50
}
```

# Setup New ESP32 Rust Project

In case you need to build the firmware for other architectures, here is how can can generate Rust dev templates for various ESP32 boards.

- General Info [ESP32 Rust Template](https://github.com/esp-rs/esp-idf-template)
- Install [ESP IDF toolchain](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/linux-macos-setup.html#step-1-install-prerequisites)
- Install [Prerequisites](https://github.com/esp-rs/esp-idf-template?tab=readme-ov-file#prerequisites)

### Install Tools

1. Install [Rustup](https://rustup.rs/)
2. Install Packages using cargo

```shell
cargo install cargo-generate
cargo install ldproxy
cargo install espup
cargo install espflash
cargo install cargo-espflash
```

3. Create Rust [Template Project](https://github.com/esp-rs/esp-idf-template?tab=readme-ov-file)

```shell
cd iot-device
cargo generate esp-rs/esp-idf-template cargo
```

### Notes

**TODO:** Checkout this alternative template! /ST 2024-11-30

- https://github.com/esp-rs/esp-generate
- https://github.com/esp-rs/esp-generate#available-options

# Compile Firmware Binary

Use the pre-build image with docker-compose to compile without any need for any local dependencies:

```shell
docker-compose up --build esp32-rust
```

Alternative, install all cargo deps locally, and then run:

```shell
cd iot-device/esp32c3
cargo build --release
```

# Flash Firmware

### Option 1 - Flash from terminal

List all usb devices on MacOS:

```zsh
ls /dev/ccu.*
ls /dev/tty.*
```

```shell
cd iot-device/esp32c3
# espflash flash target/<mcu-target>/debug/<your-project-name>
espflash flash target/riscv32imc-esp-espidf/release/esp32c3
# For monitoring, add the --montor flag:
espflash flash target/riscv32imc-esp-espidf/release/esp32c3  --monitor
```

### Option 2 - Flash with web interface

https://esp.huhn.me/

Flash firmware to memory address 0x10000
