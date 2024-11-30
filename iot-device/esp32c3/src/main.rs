// Namespaces
use esp_idf_svc::log::EspLogger;

// Specify Global Constants
const WIFI_SSID: &str = env!("WIFI_SSID");
const WIFI_PASSWORD: &str = env!("WIFI_PASSWORD");

const MQTT_SUB_TOPIC: &str = env!("MQTT_SUB_TOPIC");
const MQTT_PUB_TOPIC: &str = env!("MQTT_PUB_TOPIC");
const MQTT_PORT: &str = env!("MQTT_PORT");
const MQTT_ENDPOINT: &str = include_str!("/certs/iot_endpoint.txt");

const AWS_CERT_CA: &str = include_str!("/certs/root_ca.pem");
const AWS_CERT_CRT: &str = include_str!("/certs/iot_cert.pem");
const AWS_CERT_PRIVATE: &str = include_str!("/certs/iot_private_key.pem");

fn main() {
    esp_idf_svc::sys::link_patches(); // Required to apply ESP-IDF patches

    // Initialize logger
    EspLogger::initialize_default();

    log::info!("Hello, world!");

    log::info!("WIFI_SSID: {}", WIFI_SSID);
    log::info!("WIFI_PASSWORD: {}", WIFI_PASSWORD);

    log::info!("MQTT_SUB_TOPIC: {}", MQTT_SUB_TOPIC);
    log::info!("MQTT_PUB_TOPIC: {}", MQTT_PUB_TOPIC);
    log::info!("MQTT_PORT: {}", MQTT_PORT);
    log::info!("MQTT_ENDPOINT: {}", MQTT_ENDPOINT);

    log::info!("AWS Cert CA: {}", AWS_CERT_CA);
    log::info!("AWS Cert CRT: {}", AWS_CERT_CRT);
    log::info!("AWS Cert Private: {}", AWS_CERT_PRIVATE);
}
