// Modules
mod mqtt;
mod utils; // Debug utilities
mod wifi;

// Namespaces
use esp_idf_svc::log::EspLogger;

// fn main() {
fn main() -> Result<(), anyhow::Error> {
    // Required to apply ESP-IDF patches
    esp_idf_svc::sys::link_patches();

    // Initialize logger
    EspLogger::initialize_default();

    // Connect WIFI
    log::info!("Connecting to wifi...");
    // wifi::connect_to_wifi()?; // Use this for prod fw

    // Dev Debug (Temp WIFI): Print IP Info & and shout network presence over UDP
    let wifi = wifi::connect_to_wifi()?;
    let ip_info = wifi.wifi().sta_netif().get_ip_info()?;
    log::info!("Wi-Fi IP info: {:?}", ip_info);
    utils::broadcast_presence()?;

    // Create & Run MQTT client and connection
    let (mut client, mut conn) = mqtt::mqtt_create()?;
    mqtt::run(&mut client, &mut conn)?;

    Ok(()) // Return `Ok` for success
}
