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

pub fn broadcast_presence() -> anyhow::Result<()> {
    let socket = std::net::UdpSocket::bind("0.0.0.0:0")?; // Bind to any available port
    socket.set_broadcast(true)?; // Enable broadcasting

    let message = b"ESP32 device is online!";
    let broadcast_addr = "192.168.50.255:12345"; // Use your network's broadcast address
    socket.send_to(message, broadcast_addr)?;

    log::info!("Broadcasted presence: {}", String::from_utf8_lossy(message));

    Ok(())
}
