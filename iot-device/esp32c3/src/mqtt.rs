use core::time::Duration;
use esp_idf_sys::*; // ESP_FAIL
use log::*;

// MQTT
use esp_idf_svc::mqtt::client::*;
use esp_idf_svc::sys::EspError;

// mTLS support
use esp_idf_svc::tls::X509;
use once_cell::sync::Lazy;
use std::ffi::CString;

// Configuration from environment variables & certificates
const DEVICE_ID: &str = env!("DEVICE_ID");
const OWNER_NAME: &str = env!("OWNER_NAME");

const MQTT_URL: &str = include_str!("/certs/iot_endpoint.txt");
const MQTT_PORT: &str = env!("MQTT_PORT");
const MQTT_PUB_TOPIC: &str = env!("MQTT_PUB_TOPIC");
const MQTT_SUB_TOPIC: &str = env!("MQTT_SUB_TOPIC");

const AWS_CERT_CA: &str = include_str!("/certs/root_ca.pem");
const AWS_CERT_CRT: &str = include_str!("/certs/iot_cert.pem");
const AWS_CERT_PRIVATE: &str = include_str!("/certs/iot_private_key.pem");

pub fn run(
    client: &mut EspMqttClient<'_>,
    connection: &mut EspMqttConnection,
) -> Result<(), EspError> {
    let should_exit = std::sync::Arc::new(std::sync::atomic::AtomicBool::new(false));
    let should_exit_clone = should_exit.clone();

    let result: Result<(), Option<EspError>> = std::thread::scope(|s| {
        info!("About to start the MQTT client");
        info!("Device ID: {}", DEVICE_ID);
        info!("Owner Name: {}", OWNER_NAME);

        // Create device specific topics for publishing and subscribing
        let device_pub_topic = format!("{}/{}", DEVICE_ID, MQTT_PUB_TOPIC);
        let device_sub_topic = format!("{}/{}", DEVICE_ID, MQTT_SUB_TOPIC);

        // Spawn a separate thread to handle incoming messages
        std::thread::Builder::new()
            .stack_size(6000)
            .spawn_scoped(s, move || {
                info!("MQTT Listening for messages");

                while let Ok(event) = connection.next() {
                    match event.payload() {
                        EventPayload::Disconnected => {
                            should_exit_clone.store(true, std::sync::atomic::Ordering::Relaxed);
                            break;
                        }
                        // EventPayload::Received { data, details } => {
                        //     info!(
                        //         "Received message on topic '{}': {}",
                        //         details.topic,
                        //         String::from_utf8_lossy(data)
                        //     );
                        // }
                        _ => info!("Unhandled event: {:?}", event.payload()),
                    }

                    info!("[Queue] Event: {}", event.payload());
                }

                info!("MQTT Connection closed");
            })
            .unwrap();

        // Report connected to device shadow
        report_status(client, true);

        // Main loop: handle both publishing and subscribing
        loop {
            // If the connection is closed, exit the loop
            if should_exit.load(std::sync::atomic::Ordering::Relaxed) {
                error!("MQTT connection error detected, exiting loop");
                return Err(EspError::from(ESP_FAIL)); // Ensure the error propagates
            }

            // Subscribe to a topic
            if let Err(e) = client.subscribe(&device_sub_topic, QoS::AtMostOnce) {
                report_status(client, false);
                error!("Failed to subscribe to topic \"{device_sub_topic}\": {e}, retrying...");
            } else {
                info!("Subscribed to topic \"{device_sub_topic}\"");
            }

            // Publish a message
            let payload = format!(
                r#"{{
                    "device_id": "{}",
                    "timestamp": 1693851730,
                    "temperature": 23,
                    "humidity": 50
                }}"#,
                DEVICE_ID
            );

            match client.enqueue(
                &device_pub_topic,
                QoS::AtMostOnce,
                false,
                payload.as_bytes(),
            ) {
                Ok(_) => {
                    info!("Successfully published \"{payload}\" to topic \"{device_pub_topic}\"");
                }
                Err(e) => {
                    report_status(client, false);
                    error!("Failed to publish to topic \"{device_pub_topic}\": {e}, retrying...");
                }
            }

            // Sleep to give time for events and avoid tight looping
            std::thread::sleep(Duration::from_secs(2));
            // info!("Now sleeping for {sleep_secs}s before the next publish/subscribe cycle...");
        }
    });

    // Return the result of the thread scope
    match result {
        Ok(_) => Ok(()),
        Err(Some(e)) => Err(e), // EspError
        Err(None) => {
            let fallback_error = EspError::from_non_zero(
                std::num::NonZeroI32::new(ESP_FAIL).expect("ESP_FAIL must be non-zero"),
            );
            Err(fallback_error)
        }
    }
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
            client_id: Some(DEVICE_ID),

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

fn report_status(client: &mut EspMqttClient<'_>, connected: bool) {
    let update_shadow_topic = format!("$aws/things/{}/shadow/update", DEVICE_ID);
    let status = if connected {
        "connected"
    } else {
        "disconnected"
    };

    // JSON payload with device status
    let payload = format!(
        r#"{{
            "state": {{
                "reported": {{
                    "device_id": "{}",
                    "owner": "{}",
                    "status": "{}"
                }}
            }}
        }}"#,
        DEVICE_ID, OWNER_NAME, status
    );

    match client.enqueue(
        &update_shadow_topic, // Borrow String as &str
        QoS::AtMostOnce,
        false,
        payload.as_bytes(),
    ) {
        Ok(_) => {
            info!("Successfully published \"{payload}\" to topic \"{update_shadow_topic}\"");
        }
        Err(e) => {
            error!("Failed to publish to topic \"{update_shadow_topic}\": {e}, retrying...");
            // std::thread::sleep(Duration::from_millis(500));
            // continue;
        }
    }
}
