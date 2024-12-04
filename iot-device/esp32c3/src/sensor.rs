use once_cell::sync::Lazy;
use rand::Rng;
use std::sync::{Arc, Mutex};

pub struct SensorData {
    temperature: f32,
    humidity: f32,
}

impl SensorData {
    pub fn new(initial_temp: f32, initial_humidity: f32) -> Self {
        SensorData {
            temperature: initial_temp,
            humidity: initial_humidity,
        }
    }

    pub fn update(&mut self) {
        let mut rng = rand::thread_rng();

        // Simulate gradual changes
        self.temperature += rng.gen_range(-0.5..=0.5);
        self.humidity += rng.gen_range(-1.0..=1.0);

        // Clamp the values to realistic ranges
        self.temperature = self.temperature.clamp(15.0, 35.0);
        self.humidity = self.humidity.clamp(20.0, 80.0);
    }

    pub fn get_data(&self) -> (f32, f32) {
        (self.temperature, self.humidity)
    }
}

// Global sensor data to share across threads
pub static SENSOR: Lazy<Arc<Mutex<SensorData>>> = Lazy::new(|| {
    Arc::new(Mutex::new(SensorData::new(23.0, 50.0))) // Initial realistic values
});

// Public function to get the latest sensor data
pub fn fetch_sensor_data() -> (f32, f32) {
    let mut sensor = SENSOR.lock().unwrap();
    sensor.update(); // Update the data on each fetch
    sensor.get_data()
}
