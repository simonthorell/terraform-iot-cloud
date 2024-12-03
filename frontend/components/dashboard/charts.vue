<!-- components/dashboard/dashboard.vue -->
<template>
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

  <!-- Notification -->
  <div
    v-if="showNotification"
    class="fixed bottom-5 right-5 transition-opacity duration-300"
  >
    <div class="bg-iotGreen text-black p-3 rounded-lg shadow-md">
      <p>Charts updated!</p>
    </div>
  </div>
</template>
c
<script setup lang="ts">
import { useApi } from "@/composables/useApi";
import { useSmhi } from "~/composables/useSmhi";
import type { SmhiData } from "~/composables/useSmhi";
import type { IotData } from "~/composables/types";
import { Chart, registerables } from "chart.js";
Chart.register(...registerables);
import "chartjs-adapter-luxon";

const props = defineProps<{
  device: string;
  longitude: number | null;
  latitude: number | null;
}>();

const showNotification = ref(false);
const tempChart = ref(null);
const humidityChart = ref(null);
const tempChartInstance = ref<Chart | null>(null);
const humidityChartInstance = ref<Chart | null>(null);
const smhi_data = ref<SmhiData | null>(null);

const { fetchForecast } = useSmhi();
const { data: iot_data, fetchData } = useApi<IotData>("GetIotData");

const updateCharts = async (smhi_data: SmhiData) => {
  // Calculate the time range: Last 12 hours to the next 12 hours
  const now = new Date();
  const startTime = new Date(now.getTime() - 12 * 60 * 60 * 1000); // 12 hours back
  const endTime = new Date(now.getTime() + 12 * 60 * 60 * 1000); // 12 hours forward

  // Generate x-axis full-hour labels for the range
  const generateFullHourLabels = (start: Date, end: Date): string[] => {
    const labels: string[] = [];
    const current = new Date(start);
    while (current <= end) {
      labels.push(
        current.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })
      );
      current.setHours(current.getHours() + 1);
    }
    return labels;
  };

  const fullHourLabels = generateFullHourLabels(startTime, endTime);
  // console.log("Full-hour labels:", fullHourLabels);

  // Filter IoT data for the selected device and time range
  // const filteredIoTData = iot_data.value.filter((item) => {
  //   const timestampMs = Number(item.timestamp) * 1000; // Convert to milliseconds
  //   return (
  //     item.device_id === props.device && // Filter by selected device
  //     timestampMs >= startTime.getTime() &&
  //     timestampMs <= endTime.getTime()
  //   );
  // });

  // Filter IoT data based on device selection and time range
  const filteredIoTData = iot_data.value.filter((item) => {
    const timestampMs = Number(item.timestamp) * 1000; // Convert to milliseconds
    const isWithinTimeRange =
      timestampMs >= startTime.getTime() && timestampMs <= endTime.getTime();
    const isDeviceMatch =
      props.device === "All Devices" || item.device_id === props.device;

    return isWithinTimeRange && isDeviceMatch; // Include all devices if "All Devices" is selected
  });

  // Map IoT data to scatter points
  const iotTemperaturePoints = filteredIoTData.map((item) => ({
    x: Number(item.timestamp) * 1000, // Unix timestamp in milliseconds
    y: item.temperature,
  }));

  const iotHumidityPoints = filteredIoTData.map((item) => ({
    x: Number(item.timestamp) * 1000, // Unix timestamp in milliseconds
    y: item.humidity,
  }));

  // Filter SMHI data for the time range
  const smhiTemperatureData = smhi_data.timeSeries
    .filter((entry: any) => {
      const entryTime = new Date(entry.validTime).getTime();
      return entryTime >= startTime.getTime() && entryTime <= endTime.getTime();
    })
    .map((entry: any) => ({
      x: new Date(entry.validTime).getTime(), // Unix timestamp in milliseconds
      y:
        entry.parameters.find(
          (param: { name: string; values: number[] }) => param.name === "t"
        )?.values[0] || null,
    }));

  const smhiHumidityData = smhi_data.timeSeries
    .filter((entry: any) => {
      const entryTime = new Date(entry.validTime).getTime();
      return entryTime >= startTime.getTime() && entryTime <= endTime.getTime();
    })
    .map((entry: any) => ({
      x: new Date(entry.validTime).getTime(), // Unix timestamp in milliseconds
      y:
        entry.parameters.find(
          (param: { name: string; values: number[] }) => param.name === "r"
        )?.values[0] || null,
    }));

  console.log("IoT Temperature Points:", iotTemperaturePoints);
  console.log("IoT Humidity Points:", iotHumidityPoints);
  console.log("SMHI Temperature Data:", smhiTemperatureData);
  console.log("SMHI Humidity Data:", smhiHumidityData);

  // Destroy existing Temperature Chart instance if it exists
  if (tempChartInstance.value) {
    tempChartInstance.value.destroy();
    tempChartInstance.value = null; // Reset the instance
  }

  // Create Temperature Chart
  if (tempChart.value) {
    tempChartInstance.value = new Chart(tempChart.value as HTMLCanvasElement, {
      type: "line",
      data: {
        datasets: [
          {
            label: "Device Temperature (°C)",
            data: iotTemperaturePoints,
            borderColor: "#00ff00",
            backgroundColor: "rgba(0, 255, 0, 0.2)",
            showLine: false, // IoT points only
            pointRadius: 6,
          },
          {
            label: "SMHI Forecast Temperature (°C)",
            data: smhiTemperatureData,
            borderColor: "#ff0000",
            backgroundColor: "rgba(255, 0, 0, 0.2)",
            showLine: true, // Connect SMHI points
            pointRadius: 4,
          },
        ],
      },
      options: {
        responsive: true,
        plugins: {
          legend: {
            display: true,
          },
        },
        scales: {
          x: {
            type: "time",
            min: startTime.getTime(),
            max: endTime.getTime(),
            time: {
              unit: "hour",
              tooltipFormat: "HH:mm",
            },
            title: {
              display: true,
              text: "Time (Hours)",
            },
          },
          y: {
            title: {
              display: true,
              text: "Temperature (°C)",
            },
          },
        },
      },
    });
  }

  // Destroy existing Humidity Chart instance if it exists
  if (humidityChartInstance.value) {
    humidityChartInstance.value.destroy();
    humidityChartInstance.value = null; // Reset the instance
  }

  // Create Humidity Chart
  if (humidityChart.value) {
    humidityChartInstance.value = new Chart(
      humidityChart.value as HTMLCanvasElement,
      {
        type: "line",
        data: {
          datasets: [
            {
              label: "Device Humidity (%)",
              data: iotHumidityPoints,
              borderColor: "#00ff00",
              backgroundColor: "rgba(0, 255, 0, 0.2)",
              showLine: false, // IoT points only
              pointRadius: 6,
            },
            {
              label: "SMHI Forecast Humidity (%)",
              data: smhiHumidityData,
              borderColor: "#0000ff",
              backgroundColor: "rgba(0, 0, 255, 0.2)",
              showLine: true, // Connect SMHI points
              pointRadius: 4,
            },
          ],
        },
        options: {
          responsive: true,
          plugins: {
            legend: {
              display: true,
            },
          },
          scales: {
            x: {
              type: "time",
              min: startTime.getTime(),
              max: endTime.getTime(),
              time: {
                unit: "hour",
                tooltipFormat: "HH:mm",
              },
              title: {
                display: true,
                text: "Time (Hours)",
              },
            },
            y: {
              title: {
                display: true,
                text: "Humidity (%)",
              },
            },
          },
        },
      }
    );
  }
};

watch([() => props.device, () => props.longitude, () => props.latitude], () => {
  if (smhi_data.value) {
    updateCharts(smhi_data.value); // Unwrap the Ref here
    showNotification.value = true;
    setTimeout(() => {
      showNotification.value = false; // Hide after 3 seconds
    }, 3000);
  }
});

onMounted(async () => {
  await fetchData();

  if (props.longitude === null || props.latitude === null) {
    console.error("Longitude and latitude must be provided.");
    return;
  }

  smhi_data.value = await fetchForecast(props.longitude, props.latitude);

  if (!smhi_data.value) {
    console.error("Failed to fetch SMHI data");
    return;
  }

  updateCharts(smhi_data.value);
});
</script>
