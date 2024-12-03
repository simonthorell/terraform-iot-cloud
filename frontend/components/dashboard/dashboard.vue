<!-- components/dashboard/dashboard.vue -->
<template>
  <main class="flex-grow p-5 text-iotGreen font-mono">
    <h2 class="text-3xl mb-5">Live IoT Data</h2>

    <!-- Input Fields for Filters -->
    <div class="mb-5 grid gap-5 grid-cols-1 sm:grid-cols-3 lg:grid-cols-3">
      <div>
        <label for="device" class="block text-sm font-medium">Device</label>
        <select
          id="device"
          v-model="selectedDevice"
          class="w-full p-2 mt-1 rounded bg-iotGray text-iotGreen border border-iotGreen"
        >
          <option value="">All Devices</option>
          <option
            v-for="device in devices"
            :key="device.device_id"
            :value="device.device_id"
          >
            {{ device.device_id }}
          </option>
        </select>
      </div>
      <div>
        <label for="longitude" class="block text-sm font-medium"
          >Longitude</label
        >
        <input
          id="longitude"
          type="number"
          v-model="longitude"
          class="w-full p-2 mt-1 rounded bg-iotGray text-iotGreen border border-iotGreen"
          placeholder="Enter longitude"
        />
      </div>
      <div>
        <label for="latitude" class="block text-sm font-medium">Latitude</label>
        <input
          id="latitude"
          type="number"
          v-model="latitude"
          class="w-full p-2 mt-1 rounded bg-iotGray text-iotGreen border border-iotGreen"
          placeholder="Enter latitude"
        />
      </div>
    </div>

    <!-- IoT Data Table -->
    <charts
      :device="selectedDevice"
      :longitude="longitude"
      :latitude="latitude"
    />
  </main>
</template>
c
<script setup lang="ts">
import charts from "./charts.vue";
import { useApi } from "@/composables/useApi";

const selectedDevice = ref<string>("");
const longitude = ref<number | null>(null);
const latitude = ref<number | null>(null);

const { data: devices, fetchData: fetchDevices } = useApi<Device>("GetDevices");

// Restore longitude and latitude from localStorage
onMounted(async () => {
  await fetchDevices();

  const storedLongitude = localStorage.getItem("longitude");
  const storedLatitude = localStorage.getItem("latitude");

  if (storedLongitude) longitude.value = parseFloat(storedLongitude);
  if (storedLatitude) latitude.value = parseFloat(storedLatitude);
});

// Watch long and lat for changes and store in localStorage
watch(
  [longitude, latitude],
  ([newLongitude, newLatitude]) => {
    if (newLongitude !== null) {
      localStorage.setItem("longitude", newLongitude.toString());
    }
    if (newLatitude !== null) {
      localStorage.setItem("latitude", newLatitude.toString());
    }
  },
  { immediate: true }
);
</script>
