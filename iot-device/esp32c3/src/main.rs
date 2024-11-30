// Modules
mod mqtt;
mod wifi;

// Namespaces
use esp_idf_svc::log::EspLogger;

// Constants
const MQTT_URL: &str = include_str!("/certs/iot_endpoint.txt");
const MQTT_CLIENT_ID: &str = env!("THING_NAME");
const MQTT_TOPIC: &str = env!("MQTT_PUB_TOPIC");

const AWS_CERT_CA: &str = include_str!("/certs/root_ca.pem");
const AWS_CERT_CRT: &str = include_str!("/certs/iot_cert.pem");
const AWS_CERT_PRIVATE: &str = include_str!("/certs/iot_private_key.pem");

// fn main() {
fn main() -> Result<(), anyhow::Error> {
    esp_idf_svc::sys::link_patches(); // Required to apply ESP-IDF patches

    // Initialize logger
    EspLogger::initialize_default();

    log::info!("AWS Cert CA: {}", AWS_CERT_CA);
    log::info!("AWS Cert CRT: {}", AWS_CERT_CRT);
    log::info!("AWS Cert Private: {}", AWS_CERT_PRIVATE);

    // Connect WIFI
    log::info!("Connecting to wifi...");
    wifi::connect_to_wifi()?;

    // Start MQTT client
    let (mut client, mut conn) = mqtt::mqtt_create(MQTT_URL, MQTT_CLIENT_ID).unwrap();
    mqtt::run(&mut client, &mut conn, MQTT_TOPIC).unwrap();
    log::info!("MQTT client started");

    Ok(()) // Return `Ok` for success
}
