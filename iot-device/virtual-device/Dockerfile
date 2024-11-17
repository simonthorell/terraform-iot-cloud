# Use an official Python image as the base
FROM python:3.9-slim

# Set up the working directory
WORKDIR /app

# Install paho-mqtt
RUN pip install paho-mqtt

# Copy folder-content to the container
COPY ./iot-device/virtual-device/client.py /app

# Run the LwM2M client
CMD ["python3", "client.py"]