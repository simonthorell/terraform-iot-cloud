export interface SmhiData {
  timeSeries: any;
  device_id: string;
  timestamp: number;
  temperature: number;
  humidity: number;
}

// composables/useSmhiForecast.ts
export function useSmhi() {
  const BASE_URL = 'https://opendata-download-metfcst.smhi.se/api/category/pmp3g/version/2';

  async function fetchForecast(lat: number, lon: number): Promise<SmhiData | null> {
    try {
      const response = await fetch(`${BASE_URL}/geotype/point/lon/${lon}/lat/${lat}/data.json`);
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      const data = await response.json();

      // Extract the nearest grid point's coordinates
      const { coordinates } = data.geometry;
      const device_id = `lat:${coordinates[1]},lon:${coordinates[0]}`;

      // Find the latest forecast entry
      const latestForecast = data.timeSeries[0];
      const timestamp = new Date(latestForecast.validTime).getTime();

      // Extract temperature and humidity values
      let temperature = null;
      let humidity = null;
      for (const param of latestForecast.parameters) {
        if (param.name === 't') {
          temperature = param.values[0];
        } else if (param.name === 'r') {
          humidity = param.values[0];
        }
      }

      if (temperature === null || humidity === null) {
        throw new Error('Temperature or humidity data not found in the forecast.');
      }

      return {
        timeSeries: data.timeSeries,
        device_id,
        timestamp,
        temperature,
        humidity,
      };
    } catch (error) {
      console.error('Error fetching SMHI forecast data:', error);
      return null;
    }
  }

  return {
    fetchForecast,
  };
}