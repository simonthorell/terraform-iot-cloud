use core::time::Duration;
use log::*;

// MQTT
use esp_idf_svc::mqtt::client::*;
use esp_idf_svc::sys::EspError;

// mTLS support for MQTT
// use esp_idf_svc::tls::{self, EspTls, X509};
// use std::ffi::CStr;
// use esp_idf_svc::log::EspLogger;

const DEVICE_ID: &str = env!("DEVICE_ID");
const MQTT_URL: &str = include_str!("/certs/iot_endpoint.txt");
const MQTT_PORT: &str = env!("MQTT_PORT");
const MQTT_CLIENT_ID: &str = env!("THING_NAME");
const MQTT_SUB_TOPIC: &str = env!("MQTT_SUB_TOPIC");
const MQTT_PUB_TOPIC: &str = env!("MQTT_PUB_TOPIC");
// const AWS_CERT_CA: &str = include_str!("/certs/root_ca.pem");
// const AWS_CERT_CRT: &str = include_str!("/certs/iot_cert.pem");
// const AWS_CERT_PRIVATE: &str = include_str!("/certs/iot_private_key.pem");

pub fn run(
    client: &mut EspMqttClient<'_>,
    connection: &mut EspMqttConnection,
) -> Result<(), EspError> {
    std::thread::scope(|s| {
        info!("About to start the MQTT client");

        // Spawn a separate thread to handle incoming messages
        std::thread::Builder::new()
            .stack_size(6000)
            .spawn_scoped(s, move || {
                info!("MQTT Listening for messages");

                while let Ok(event) = connection.next() {
                    info!("[Queue] Event: {}", event.payload());
                }

                info!("Connection closed");
            })
            .unwrap();

        // Main loop: handle both publishing and subscribing
        loop {
            // Subscribe to a topic
            if let Err(e) = client.subscribe(MQTT_SUB_TOPIC, QoS::AtMostOnce) {
                error!("Failed to subscribe to topic \"{MQTT_SUB_TOPIC}\": {e}, retrying...");
                std::thread::sleep(Duration::from_millis(500));
                continue;
            }
            info!("Subscribed to topic \"{MQTT_SUB_TOPIC}\"");

            // Publish a message
            let payload = "Hello from esp-mqtt-demo!";
            match client.enqueue(MQTT_PUB_TOPIC, QoS::AtMostOnce, false, payload.as_bytes()) {
                Ok(_) => {
                    info!("Successfully published \"{payload}\" to topic \"{MQTT_PUB_TOPIC}\"");
                }
                Err(e) => {
                    error!("Failed to publish to topic \"{MQTT_PUB_TOPIC}\": {e}, retrying...");
                    std::thread::sleep(Duration::from_millis(500));
                    continue;
                }
            }

            // Sleep to give time for events and avoid tight looping
            let sleep_secs = 2;
            info!("Now sleeping for {sleep_secs}s before the next publish/subscribe cycle...");
            std::thread::sleep(Duration::from_secs(sleep_secs));
        }
    })
}

pub fn mqtt_create() -> Result<(EspMqttClient<'static>, EspMqttConnection), EspError> {
    let full_mqtt_url = format!("mqtt://{}:{}", MQTT_URL.trim(), MQTT_PORT);

    // let mut tls = EspTls::new()?;
    // tls.connect(
    //     MQTT_URL.trim(),
    //     MQTT_PORT.parse::<u16>().unwrap_or(8883),
    //     &tls::Config {
    //         common_name: Some(MQTT_URL.trim()),
    //         ca_cert: Some(X509::pem(
    //             CStr::from_bytes_with_nul(AWS_CERT_CA.as_bytes()).unwrap(),
    //         )),
    //         client_cert: Some(X509::pem(
    //             CStr::from_bytes_with_nul(AWS_CERT_CRT.as_bytes()).unwrap(),
    //         )),
    //         private_key: Some(X509::pem(
    //             CStr::from_bytes_with_nul(AWS_CERT_PRIVATE.as_bytes()).unwrap(),
    //         )),
    //         ..Default::default()
    //     },
    // )?;

    // // Configure MQTT with mTLS
    // let (mqtt_client, mqtt_conn) = EspMqttClient::new(
    //     &format!("mqtts://{}", full_mqtt_url),
    //     &MqttClientConfiguration {
    //         client_id: Some(MQTT_CLIENT_ID),
    //         // Ensure TLS transport
    //         // tls_configuration: Some(tls),
    //         keep_alive_interval: std::time::Duration::from_secs(60),
    //         ..Default::default()
    //     },
    // )?;

    // Configure MQTT without mTLS
    let (mqtt_client, mqtt_conn) = EspMqttClient::new(
        &full_mqtt_url,
        &MqttClientConfiguration {
            client_id: Some(MQTT_CLIENT_ID),
            keep_alive_interval: Some(Duration::from_secs(60)),
            ..Default::default()
        },
    )?;

    Ok((mqtt_client, mqtt_conn))
}
