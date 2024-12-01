use core::time::Duration;
use log::*;

// MQTT
use esp_idf_svc::mqtt::client::*;
use esp_idf_svc::sys::EspError;

// mTLS support for MQTT
use esp_idf_svc::tls::X509;
use once_cell::sync::Lazy;
use std::ffi::CString;

// Namespaces
use esp_idf_svc::log::EspLogger;

const MQTT_URL: &str = include_str!("/certs/iot_endpoint.txt");
const MQTT_PORT: &str = env!("MQTT_PORT");
const MQTT_CLIENT_ID: &str = env!("DEVICE_ID");
const MQTT_SUB_TOPIC: &str = env!("MQTT_SUB_TOPIC");
const MQTT_PUB_TOPIC: &str = env!("MQTT_PUB_TOPIC");

const AWS_CERT_CA: &str = include_str!("/certs/root_ca.pem");
const AWS_CERT_CRT: &str = include_str!("/certs/iot_cert.pem");
const AWS_CERT_PRIVATE: &str = include_str!("/certs/iot_private_key.pem");

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
            // if let Err(e) = client.subscribe(MQTT_SUB_TOPIC, QoS::AtMostOnce) {
            //     error!("Failed to subscribe to topic \"{MQTT_SUB_TOPIC}\": {e}, retrying...");
            //     std::thread::sleep(Duration::from_millis(500));
            //     continue;
            // }
            // info!("Subscribed to topic \"{MQTT_SUB_TOPIC}\"");

            // Publish a message
            // let payload = "Hello from esp-mqtt-demo!";
            let payload = r#"{"device_id": "Hello from esp-mqtt-demo!"}"#;
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
    let full_mqtt_url = format!("mqtts://{}:{}", MQTT_URL.trim(), MQTT_PORT);
    log::info!("FULL MQTT URL: {}", full_mqtt_url);

    // Store PEM certificates as static CStrings to extend their lifetime
    static CA_CERT: Lazy<CString> =
        Lazy::new(|| CString::new(AWS_CERT_CA).expect("CA cert conversion failed"));
    static CLIENT_CERT: Lazy<CString> =
        Lazy::new(|| CString::new(AWS_CERT_CRT).expect("Client cert conversion failed"));
    static CLIENT_KEY: Lazy<CString> =
        Lazy::new(|| CString::new(AWS_CERT_PRIVATE).expect("Private key conversion failed"));

    // Log certificates before configuring MQTT
    // info!("CA_CERT: {:?}", CA_CERT.as_c_str());
    // info!("CLIENT_CERT: {:?}", CLIENT_CERT.as_c_str());
    // info!("CLIENT_KEY: {:?}", CLIENT_KEY.as_c_str());

    // Configure MQTT with mTLS
    let (mqtt_client, mqtt_conn) = EspMqttClient::new(
        &format!("{}", full_mqtt_url),
        &MqttClientConfiguration {
            client_id: Some(MQTT_CLIENT_ID),

            // mTLS certificates
            server_certificate: Some(X509::pem(CA_CERT.as_c_str())),
            client_certificate: Some(X509::pem(CLIENT_CERT.as_c_str())),
            private_key: Some(X509::pem(CLIENT_KEY.as_c_str())),

            keep_alive_interval: Some(Duration::from_secs(60)),
            ..Default::default()
        },
    )?;

    Ok((mqtt_client, mqtt_conn))
}
