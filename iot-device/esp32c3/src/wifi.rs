use core::convert::TryInto;

use embedded_svc::wifi::{AuthMethod, ClientConfiguration, Configuration};
use esp_idf_svc::hal::prelude::Peripherals;
use esp_idf_svc::wifi::{BlockingWifi, EspWifi};
use esp_idf_svc::{eventloop::EspSystemEventLoop, nvs::EspDefaultNvsPartition};

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
