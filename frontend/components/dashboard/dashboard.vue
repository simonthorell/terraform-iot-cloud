<!-- components/dashboard/dashboard.vue -->
<template>
  <main class="flex-grow p-5 text-iotGreen font-mono">
    <h2 class="text-3xl mb-5">Live IoT Data</h2>
    <div class="grid gap-5 grid-cols-1 sm:grid-cols-2 lg:grid-cols-3">
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

      <!-- Network Activity Chart -->
      <div class="bg-iotGray p-5 rounded-lg shadow-md shadow-iotGreen">
        <h3 class="text-center text-xl mb-5">Network Activity</h3>
        <canvas ref="networkChart"></canvas>
      </div>
    </div>
  </main>
</template>

<script setup lang="ts">
import { useApi } from "@/composables/useApi";
import { Chart, registerables } from "chart.js";
Chart.register(...registerables);

const tempChart = ref(null);
const humidityChart = ref(null);
const networkChart = ref(null);

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
  await fetchData(); // Wait until iot_data is fetched
  // console.log("IoT Data:", iot_data.value);

  // Extract real data
  const labels = iot_data.value.map((item) =>
    new Date(Number(item.timestamp) * 1000).toLocaleTimeString()
  );
  const temperatureData = iot_data.value.map((item) => item.temperature || 0);
  const humidityData = iot_data.value.map((item) => item.humidity || 0);
  const networkData = iot_data.value.map((item) => 0); // If network exists

  if (tempChart.value) {
    new Chart(tempChart.value as HTMLCanvasElement, {
      type: "line",
      data: {
        labels, // Use real timestamps
        datasets: [
          {
            label: "Temperature (°C)",
            data: temperatureData, // Use real temperature data
            borderColor: "#00ff00",
            backgroundColor: "rgba(0, 255, 0, 0.2)",
          },
        ],
      },
      options: { responsive: true, plugins: { legend: { display: false } } },
    });
  }

  if (humidityChart.value) {
    new Chart(humidityChart.value as HTMLCanvasElement, {
      type: "line",
      data: {
        labels, // Use real timestamps
        datasets: [
          {
            label: "Humidity (%)",
            data: humidityData, // Use real humidity data
            borderColor: "#00ff00",
            backgroundColor: "rgba(0, 255, 0, 0.2)",
          },
        ],
      },
      options: { responsive: true, plugins: { legend: { display: false } } },
    });
  }

  if (networkChart.value) {
    new Chart(networkChart.value as HTMLCanvasElement, {
      type: "bar",
      data: {
        labels, // Use real timestamps
        datasets: [
          {
            label: "Network (kB/s)",
            data: networkData, // Use real network data
            backgroundColor: "#00ff00",
          },
        ],
      },
      options: { responsive: true, plugins: { legend: { display: false } } },
    });
  }
});
</script>
