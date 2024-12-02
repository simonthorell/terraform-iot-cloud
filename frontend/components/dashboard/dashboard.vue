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

const temperatureData = [22, 23, 21, 24, 26, 27, 25];
const humidityData = [45, 48, 46, 50, 52, 49, 47];
const networkData = [5, 6, 8, 4, 7, 9, 6];

const tempChart = ref(null);
const humidityChart = ref(null);
const networkChart = ref(null);

// Define the Device type
interface IotData {
  device_id: string;
  timestamp: Number;
  data: string;
}

const {
  data: iot_data,
  loading,
  error,
  fetchData,
} = useApi<IotData>("GetIotData");

onMounted(async () => {
  await fetchData();
  console.log("IoT Data:", iot_data.value);

  if (tempChart.value) {
    new Chart(tempChart.value as HTMLCanvasElement, {
      type: "line",
      data: {
        labels: Array.from(
          { length: temperatureData.length },
          (_, i) => `T${i + 1}`
        ),
        datasets: [
          {
            label: "Temperature (°C)",
            data: temperatureData,
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
        labels: Array.from(
          { length: humidityData.length },
          (_, i) => `H${i + 1}`
        ),
        datasets: [
          {
            label: "Humidity (%)",
            data: humidityData,
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
        labels: Array.from(
          { length: networkData.length },
          (_, i) => `N${i + 1}`
        ),
        datasets: [
          {
            label: "Network (kB/s)",
            data: networkData,
            backgroundColor: "#00ff00",
          },
        ],
      },
      options: { responsive: true, plugins: { legend: { display: false } } },
    });
  }
});
</script>
