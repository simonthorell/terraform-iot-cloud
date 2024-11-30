use core::time::Duration;

use esp_idf_svc::mqtt::client::*;
use esp_idf_svc::sys::EspError;
// use esp_idf_svc::tls::configuration::TlsConfiguration;

use log::*;

// Constants
// const MQTT_URL: &str = concat!("mqtts://", include_str!("/certs/iot_endpoint.txt"), ":8883");
const MQTT_URL: &str = include_str!("/certs/iot_endpoint.txt");
const MQTT_PORT: &str = env!("MQTT_PORT");
const MQTT_CLIENT_ID: &str = env!("THING_NAME");
const MQTT_TOPIC: &str = env!("MQTT_PUB_TOPIC");

// Paths or contents of your TLS certificates
// const AWS_CERT_CA: &str = include_str!("/certs/root_ca.pem");
// const AWS_CERT_CRT: &str = include_str!("/certs/iot_cert.pem");
// const AWS_CERT_PRIVATE: &str = include_str!("/certs/iot_private_key.pem");

pub fn run(
    client: &mut EspMqttClient<'_>,
    connection: &mut EspMqttConnection,
    // topic: &str,
) -> Result<(), EspError> {
    std::thread::scope(|s| {
        info!("About to start the MQTT client");

        // Need to immediately start pumping the connection for messages, or else subscribe() and publish() below will not work
        // Note that when using the alternative constructor - `EspMqttClient::new_cb` - you don't need to
        // spawn a new thread, as the messages will be pumped with a backpressure into the callback you provide.
        // Yet, you still need to efficiently process each message in the callback without blocking for too long.
        //
        // Note also that if you go to http://tools.emqx.io/ and then connect and send a message to topic
        // "esp-mqtt-demo", the client configured here should receive it.
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

        loop {
            if let Err(e) = client.subscribe(MQTT_TOPIC, QoS::AtMostOnce) {
                error!("Failed to subscribe to topic \"{MQTT_TOPIC}\": {e}, retrying...");

                // Re-try in 0.5s
                std::thread::sleep(Duration::from_millis(500));

                continue;
            }

            info!("Subscribed to topic \"{MQTT_TOPIC}\"");

            // Just to give a chance of our connection to get even the first published message
            std::thread::sleep(Duration::from_millis(500));

            let payload = "Hello from esp-mqtt-demo!";

            loop {
                client.enqueue(MQTT_TOPIC, QoS::AtMostOnce, false, payload.as_bytes())?;

                info!("Published \"{payload}\" to topic \"{MQTT_TOPIC}\"");

                let sleep_secs = 2;

                info!("Now sleeping for {sleep_secs}s...");
                std::thread::sleep(Duration::from_secs(sleep_secs));
            }
        }
    })
}

pub fn mqtt_create() -> Result<(EspMqttClient<'static>, EspMqttConnection), EspError> {
    let full_mqtt_url = format!("mqtts://{}:{}", MQTT_URL.trim(), MQTT_PORT);

    let (mqtt_client, mqtt_conn) = EspMqttClient::new(
        &full_mqtt_url,
        &MqttClientConfiguration {
            client_id: Some(MQTT_CLIENT_ID),
            // transport: Transport::Tls,
            ..Default::default()
        },
    )?;

    Ok((mqtt_client, mqtt_conn))
}
