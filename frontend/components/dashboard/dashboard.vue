<!-- components/dashboard/dashboard.vue -->
<template>
  <main class="flex-grow p-5 text-iotGreen font-mono">
    <h2 class="text-3xl mb-5">Live IoT Data</h2>
    <div class="grid gap-5 grid-cols-1 sm:grid-cols-2 lg:grid-cols-2">
      <!-- Temperature Meter -->
      <div class="bg-iotGray p-5 rounded-lg shadow-md shadow-iotGreen">
        <h3 class="text-center text-xl mb-5">Temperature</h3>
        <canvas ref="tempChart"></canvas>
      </div>
      <!-- Humidity Meter -->
      <div class="bg-iotGray p-5 rounded-lg shadow-md shadow-iotGreen">
        <h3 class="text-center text-xl mb-5">Humidity</h3>
        <canvas ref="humidityChart"></canvas>
      </div>
    </div>
  </main>
</template>
c
<script setup lang="ts">
import { useApi } from "@/composables/useApi";
import { useSmhi } from "~/composables/useSmhi";
import { Chart, registerables } from "chart.js";
Chart.register(...registerables);

const tempChart = ref(null);
const humidityChart = ref(null);

const { fetchForecast } = useSmhi();

// Define the Device typee
interface IotData {
  device_id: string;
  timestamp: number;
  temperature: number;
  humidity: number;
}

const {
  data: iot_data,
  loading,
  error,
  fetchData,
} = useApi<IotData>("GetIotData");

onMounted(async () => {
  await fetchData(); // Fetch IoT data
  const smhi_data = await fetchForecast(59.7246, 17.1016); // Fetch SMHI forecast data

  if (!smhi_data) {
    console.error("Failed to fetch SMHI data");
    return;
  }

  // Merge IoT and SMHI Data
  const currentTime = Date.now();
  const pastHours = 6 * 60 * 60 * 1000; // Last 6 hours
  const smhiLastHours = smhi_data.timeSeries.filter(
    (entry: { validTime: string | number | Date }) => {
      const forecastTime = new Date(entry.validTime).getTime();
      return forecastTime >= currentTime - pastHours;
    }
  );

  const labels = iot_data.value.map((item) =>
    new Date(Number(item.timestamp) * 1000).toLocaleTimeString()
  );
  const temperatureData = iot_data.value.map((item) => item.temperature || 0);
  const humidityData = iot_data.value.map((item) => item.humidity || 0);

  // Add SMHI Data to Charts
  const smhiTimestamps = smhiLastHours.map(
    (entry: { validTime: string | number | Date }) =>
      new Date(entry.validTime).toLocaleTimeString()
  );
  const smhiTemperatureData = smhiLastHours.map(
    (entry: { parameters: any[] }) =>
      entry.parameters.find((param: { name: string }) => param.name === "t")
        ?.values[0] || 0
  );
  const smhiHumidityData = smhiLastHours.map(
    (entry: { parameters: any[] }) =>
      entry.parameters.find((param: { name: string }) => param.name === "r")
        ?.values[0] || 0
  );

  // Temperature Chart
  if (tempChart.value) {
    new Chart(tempChart.value as HTMLCanvasElement, {
      type: "line",
      data: {
        labels: [...labels, ...smhiTimestamps],
        datasets: [
          {
            label: "IoT Temperature (°C)",
            data: temperatureData,
            borderColor: "#00ff00",
            backgroundColor: "rgba(0, 255, 0, 0.2)",
          },
          {
            label: "SMHI Forecast Temperature (°C)",
            data: smhiTemperatureData,
            borderColor: "#ff0000",
            backgroundColor: "rgba(255, 0, 0, 0.2)",
          },
        ],
      },
      options: {
        responsive: true,
        plugins: { legend: { display: true } },
      },
    });
  }

  // Humidity Chart
  if (humidityChart.value) {
    new Chart(humidityChart.value as HTMLCanvasElement, {
      type: "line",
      data: {
        labels: [...labels, ...smhiTimestamps],
        datasets: [
          {
            label: "IoT Humidity (%)",
            data: humidityData,
            borderColor: "#00ff00",
            backgroundColor: "rgba(0, 255, 0, 0.2)",
          },
          {
            label: "SMHI Forecast Humidity (%)",
            data: smhiHumidityData,
            borderColor: "#0000ff",
            backgroundColor: "rgba(0, 0, 255, 0.2)",
          },
        ],
      },
      options: {
        responsive: true,
        plugins: { legend: { display: true } },
      },
    });
  }
});
</script>
