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
MQTT_TOPIC = "iot/data"
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


# Initializing starting points for metrics
initial_operating_hours = 5271.2  # Starting total operating hours
initial_driving_distance = 1314.6  # Starting total driving distance in km
initial_runtime = 0.0  # Current runtime in hours since start

# Set incremental values for each interval
operating_hours_increment = DATA_INTERVAL / 3600.0  # Increase by X seconds in hours
driving_distance_increment = 0.1  # Increase by 0.1 km (6 km/h average speed in 5 seconds)
runtime_increment = DATA_INTERVAL / 3600.0  # Increase by X seconds in hours for runtime


def generate_iot_data():
    global initial_operating_hours, initial_driving_distance, initial_runtime

    # Increment the metrics realistically
    initial_operating_hours += operating_hours_increment
    initial_driving_distance += driving_distance_increment
    initial_runtime += runtime_increment

    # Reset runtime if it reaches a realistic daily limit
    if initial_runtime > 24.0:  # Assuming daily restarts
        initial_runtime = 0.0

    # Generating data dictionary with realistic increments
    data = {
        "engine_temperature":
        round(85.0 + (initial_runtime * 1.5) + random.uniform(-4.0, 4.0),
              2),  # Add temp fluctuation
        "engine_oil_pressure":
        round(50.0 - (initial_runtime * 0.2) + random.uniform(-3.0, 3.0),
              2),  # Add pressure fluctuation
        "total_operating_hours":
        round(initial_operating_hours, 2),
        "total_driving_distance":
        round(initial_driving_distance, 2),
        "current_runtime":
        round(initial_runtime, 2),
        "timestamp":
        int(time.time())  # Current timestamp in UNIX format
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