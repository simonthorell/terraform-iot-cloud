use core::convert::TryInto;

use embedded_svc::wifi::{AuthMethod, ClientConfiguration, Configuration};
use esp_idf_svc::hal::prelude::Peripherals;
use esp_idf_svc::wifi::{BlockingWifi, EspWifi};
use esp_idf_svc::{eventloop::EspSystemEventLoop, nvs::EspDefaultNvsPartition};

// use esp_idf_sys::*;
use log::info;

// Use the environment variables for Wi-Fi SSID and password
const SSID: &str = env!("WIFI_SSID");
const PASSWORD: &str = env!("WIFI_PASSWORD");

// Function to set up and connect to Wi-Fi
// pub fn connect_to_wifi() -> anyhow::Result<()> {
pub fn connect_to_wifi() -> anyhow::Result<BlockingWifi<EspWifi<'static>>> {
    let peripherals = Peripherals::take()?;
    let sys_loop = EspSystemEventLoop::take()?;
    let nvs = EspDefaultNvsPartition::take()?;

    let mut wifi = BlockingWifi::wrap(
        EspWifi::new(peripherals.modem, sys_loop.clone(), Some(nvs))?,
        sys_loop,
    )?;

    let wifi_configuration: Configuration = Configuration::Client(ClientConfiguration {
        ssid: SSID.try_into().unwrap(),
        bssid: None,
        auth_method: AuthMethod::WPA2Personal,
        password: PASSWORD.try_into().unwrap(),
        channel: None,
        ..Default::default()
    });

    wifi.set_configuration(&wifi_configuration)?;

    wifi.start()?;
    info!("Wi-Fi started");

    wifi.connect()?;
    info!("Wi-Fi connected");

    wifi.wait_netif_up()?;
    info!("Wi-Fi netif up");

    let ip_info = wifi.wifi().sta_netif().get_ip_info()?;
    info!("Wi-Fi IP info: {:?}", ip_info);

    // Ok(())
    Ok(wifi) // Return the `BlockingWifi` instance
}

// use esp_idf_sys::EspError;

// pub fn reset_wifi() -> Result<(), EspError> {
//     log::info!("Resetting Wi-Fi stack...");

//     // Stop the Wi-Fi driver if it's running
//     let stop_result = unsafe { esp_idf_sys::esp_wifi_stop() };
//     if stop_result != 0 {
//         log::warn!(
//             "Failed to stop Wi-Fi: {:?}",
//             EspError::from_non_zero(stop_result.try_into().unwrap())
//         );
//     }

//     // Deinitialize Wi-Fi driver
//     let deinit_result = unsafe { esp_idf_sys::esp_wifi_deinit() };
//     if deinit_result != 0 {
//         log::warn!(
//             "Failed to deinitialize Wi-Fi: {:?}",
//             EspError::from_non_zero(deinit_result.try_into().unwrap())
//         );
//     }

//     // Reinitialize Wi-Fi driver
//     let init_result =
//         unsafe { esp_idf_sys::esp_wifi_init(&esp_idf_sys::wifi_init_config_t::default()) };
//     if init_result != 0 {
//         log::error!(
//             "Failed to reinitialize Wi-Fi: {:?}",
//             EspError::from_non_zero(init_result.try_into().unwrap())
//         );
//         return Err(EspError::from_non_zero(init_result.try_into().unwrap()));
//     }

//     log::info!("Wi-Fi stack reset completed.");
//     Ok(())
// }

// pub fn clean_up_wifi(wifi: &mut BlockingWifi<EspWifi>) -> Result<(), EspError> {
//     if let Err(e) = wifi.stop() {
//         if e.code() != ESP_ERR_WIFI_NOT_STARTED {
//             log::error!("Failed to stop Wi-Fi: {:?}", e);
//             return Err(e);
//         } else {
//             log::warn!("Wi-Fi not started, skipping stop.");
//         }
//     }

//     if let Err(e) = wifi.disconnect() {
//         if e.code() != ESP_ERR_WIFI_NOT_STARTED {
//             log::error!("Failed to disconnect Wi-Fi: {:?}", e);
//             return Err(e);
//         } else {
//             log::warn!("Wi-Fi not started, skipping disconnect.");
//         }
//     }

//     log::info!("Wi-Fi successfully cleaned up.");
//     Ok(())
// }
