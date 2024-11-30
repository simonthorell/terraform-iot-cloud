// Modules
mod mqtt;
mod wifi;

// Namespaces
use esp_idf_svc::log::EspLogger;

// fn main() {
fn main() -> Result<(), anyhow::Error> {
    esp_idf_svc::sys::link_patches(); // Required to apply ESP-IDF patches

    // Initialize logger
    EspLogger::initialize_default();

    // Connect WIFI
    log::info!("Connecting to wifi...");
    // wifi::connect_to_wifi()?; // Use this for prod fw
    let wifi = wifi::connect_to_wifi()?;

    // DEV DEBUG: Access IP Information & and shout out presence on the network over UDP
    let ip_info = wifi.wifi().sta_netif().get_ip_info()?;
    log::info!("Wi-Fi IP info: {:?}", ip_info);
    broadcast_presence()?;

    // Create & Run MQTT client and connection
    let (mut client, mut conn) = mqtt::mqtt_create()?;
    mqtt::run(&mut client, &mut conn)?;

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
