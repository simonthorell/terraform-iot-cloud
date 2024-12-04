// Modules
mod mqtt;
mod sensor;
mod utils;
mod wifi; // Debug utilities

// Namespaces
use anyhow::Error;
use esp_idf_svc::log::EspLogger;
use esp_idf_sys::*;

fn main() -> Result<(), anyhow::Error> {
    esp_idf_svc::sys::link_patches();
    EspLogger::initialize_default();

    loop {
        log::info!("Connecting to Wi-Fi...");
        let wifi = match wifi::connect_to_wifi() {
            Ok(wifi) => wifi,
            Err(e) => {
                log::error!("Failed to connect to Wi-Fi: {:?}", e);
                handle_esp_error(e); // Check if we need to reboot
                std::thread::sleep(std::time::Duration::from_secs(5));
                continue;
            }
        };

        // Log Wi-Fi IP info
        let ip_info = wifi.wifi().sta_netif().get_ip_info()?;
        log::info!("Wi-Fi IP info: {:?}", ip_info);
        utils::broadcast_presence()?;

        log::info!("Wi-Fi connected. Starting MQTT client...");
        match mqtt::mqtt_create() {
            Ok((mut client, mut conn)) => {
                if let Err(e) = mqtt::run(&mut client, &mut conn) {
                    log::error!("MQTT run failed: {:?}", e);
                }
            }
            Err(e) => {
                log::error!("Failed to create MQTT client: {:?}", e);
            }
        }

        // log::warn!("Restarting Wi-Fi and MQTT connection...");
        // if let Err(e) = wifi::clean_up_wifi(&mut wifi) {
        //     log::error!("Failed to clean up Wi-Fi: {:?}", e);
        // }
        // if let Err(e) = wifi::reset_wifi() {
        //     log::error!("Failed to reset Wi-Fi: {:?}", e);
        // }

        std::thread::sleep(std::time::Duration::from_secs(3));
    }
}

fn handle_esp_error(err: Error) {
    if let Some(esp_error) = err.downcast_ref::<EspError>() {
        if esp_error.code() == ESP_ERR_INVALID_STATE {
            log::error!("ESP_ERR_INVALID_STATE encountered. Restarting device...");
            unsafe { esp_restart() };
        }
    }
    log::error!("Unhandled error: {:?}", err);
}
