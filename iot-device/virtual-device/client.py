import paho.mqtt.client as mqtt
import time
import json
import random
import os
import ssl

# Get MQTT broker Endpoint from file
with open('/certs/iot_endpoint.txt', 'r') as file:
    iot_endpoint = file.read().strip()

# MQTT settings
MQTT_ENDPOINT = iot_endpoint
MQTT_PORT = 8883
MQTT_TOPIC = "279/telemetry"
CA_CERT = "/certs/root_ca.pem"
CLIENT_CERT = "/certs/iot_cert.pem"
CLIENT_KEY = "/certs/iot_private_key.pem"

DATA_INTERVAL = 5  # Data publishing interval in seconds

print("IoT Client started...")


# Callback when connecting to the MQTT broker
def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("Connected to MQTT Broker!")
    else:
        print(f"Failed to connect with code {rc}")


# Data Generation
def generate_iot_data():
    """Generate IoT data for publishing."""
    data = {
        "device_id": "279",  # Device ID
        "timestamp": int(time.time()),  # Current UNIX timestamp
        "temperature": round(20.0 + random.uniform(-30.0, 30.0),
                             2),  # Temperature in °C
        "humidity": round(40.0 + random.uniform(-30.0, 30.0),
                          2),  # Humidity in %
    }
    return data


# Initialize MQTT client
client = mqtt.Client()
client.on_connect = on_connect

# Set up TLS configuration
client.tls_set(ca_certs=CA_CERT,
               certfile=CLIENT_CERT,
               keyfile=CLIENT_KEY,
               tls_version=ssl.PROTOCOL_TLSv1_2)
client.tls_insecure_set(True)  # Enforce server certificate verification

# Connect to the MQTT broker
client.connect(MQTT_ENDPOINT, MQTT_PORT, keepalive=60)

# Loop to send data at intervals
client.loop_start()
try:
    while True:
        # Generate and publish IoT data as JSON
        data = generate_iot_data()
        payload = json.dumps(data)
        client.publish(MQTT_TOPIC, payload)
        print(f"Published data: {payload}")
        time.sleep(DATA_INTERVAL)  # Publish interval in seconds

except KeyboardInterrupt:
    print("Stopping publisher...")
finally:
    client.loop_stop()
    client.disconnect()
