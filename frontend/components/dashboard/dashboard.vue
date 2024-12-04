<!-- components/dashboard/dashboard.vue -->
<template>
  <main class="flex-grow p-5 text-iotGreen font-mono">
    <div class="flex justify-between items-center mb-5">
      <h2 class="text-3xl">Live Iot Data</h2>
      <button
        @click="handleRefresh"
        :disabled="loading"
        class="text-iotGreen bg-iotBlack border border-iotGreen hover:bg-iotGreen hover:text-black transition duration-300 py-2 px-4 rounded-lg"
      >
        Refresh
      </button>
    </div>

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

    <!-- Show Spinner While Loading -->
    <div v-if="loading" class="flex justify-center items-center mt-10">
      <div
        class="animate-spin rounded-full h-16 w-16 border-t-4 border-iotGreen border-solid border-opacity-50"
      ></div>
      <p class="text-xl ml-4">Loading charts...</p>
    </div>

    <!-- Render Charts After Loading -->
    <charts
      v-if="!loading"
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

const loading = ref(true);
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

  loading.value = false; // Mark loading as complete
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

// Refresh handler
const handleRefresh = async () => {
  loading.value = true; // Start loading
  await fetchDevices(); // Fetch devices
  loading.value = false; // End loading
};
</script>
