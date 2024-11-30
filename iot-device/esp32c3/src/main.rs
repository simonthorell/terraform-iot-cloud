// Modules
// mod mqtt;
mod wifi;

// Namespaces
use esp_idf_svc::log::EspLogger;

// Constants
// const MQTT_URL: &str = include_str!("/certs/iot_endpoint.txt");
// const MQTT_CLIENT_ID: &str = env!("THING_NAME");
// const MQTT_TOPIC: &str = env!("MQTT_PUB_TOPIC");

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
    // wifi::connect_to_wifi()?;
    let wifi = wifi::connect_to_wifi()?; // `wifi` is now the `BlockingWifi` object

    // Access IP Information
    let ip_info = wifi.wifi().sta_netif().get_ip_info()?;
    log::info!("Wi-Fi IP info: {:?}", ip_info);

    // Shout out presence on the network!
    broadcast_presence()?;

    // Start MQTT client
    // let (mut client, mut conn) = mqtt::mqtt_create(MQTT_URL, MQTT_CLIENT_ID).unwrap();
    // mqtt::run(&mut client, &mut conn, MQTT_TOPIC).unwrap();
    // log::info!("MQTT client started");

    Ok(()) // Return `Ok` for success
}

/**
* Debug function to scream out over UDP that device is online
*
* Example:
* let wifi = wifi::connect_to_wifi()?; // `wifi` is now the `BlockingWifi` object
* let ip_info = wifi.wifi().sta_netif().get_ip_info()?;
* log::info!("Wi-Fi IP info: {:?}", ip_info);
* broadcast_presence()?;
*
* In the monitor console you should see:
* esp_netif_handlers: sta ip: <IP-ADDRESS>, mask: <MASK-ADDRESS>, gw: <ROUTER-ADDRESS>
*
* In WireShark, filter for "ip.addr == <IP-ADDRESS>"
*/

fn broadcast_presence() -> anyhow::Result<()> {
    let socket = std::net::UdpSocket::bind("0.0.0.0:0")?; // Bind to any available port
    socket.set_broadcast(true)?; // Enable broadcasting

    let message = b"ESP32 device is online!";
    let broadcast_addr = "192.168.50.255:12345"; // Use your network's broadcast address
    socket.send_to(message, broadcast_addr)?;

    log::info!("Broadcasted presence: {}", String::from_utf8_lossy(message));

    Ok(())
}
