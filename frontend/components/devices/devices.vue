<template>
  <main class="flex-grow p-5 text-iotGreen font-mono">
    <div class="flex justify-between items-center mb-5">
      <h2 class="text-3xl">Devices</h2>
      <button
        @click="() => fetchData()"
        :disabled="loading"
        class="text-iotGreen bg-iotBlack border border-iotGreen hover:bg-iotGreen hover:text-black transition duration-300 py-2 px-4 rounded-lg"
      >
        Refresh
      </button>
    </div>

    <!-- Show Spinner While Loading -->
    <div v-if="loading" class="flex justify-center items-center mt-10">
      <div
        class="animate-spin rounded-full h-16 w-16 border-t-4 border-iotGreen border-solid border-opacity-50"
      ></div>
      <p class="text-xl ml-4">Loading charts...</p>
    </div>

    <!-- Devices Table -->
    <div
      v-if="!loading"
      class="bg-iotGray p-5 rounded-lg shadow-md shadow-iotGreen"
    >
      <table class="table-auto w-full text-left border-collapse">
        <thead>
          <tr>
            <th class="border-b border-iotGreen py-2 px-4 text-xl">
              Device ID
            </th>
            <th class="border-b border-iotGreen py-2 px-4 text-xl">Owner</th>
            <th class="border-b border-iotGreen py-2 px-4 text-xl">Status</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="device in devices"
            :key="device.device_id"
            class="hover:bg-iotGreen hover:text-black transition duration-300"
          >
            <td class="py-2 px-4">{{ device.device_id }}</td>
            <td class="py-2 px-4">{{ device.owner }}</td>
            <td
              class="py-2 px-4 font-bold"
              :class="{
                'text-green-500': device.status === 'Online',
                'text-red-500': device.status === 'Offline',
              }"
            >
              {{ device.status }}
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </main>
</template>

<script setup lang="ts">
import { useApi } from "@/composables/useApi";

// Define the Device type
interface Device {
  device_id: string;
  owner: string;
  status: string;
}

const {
  data: devices,
  loading,
  error,
  fetchData,
} = useApi<Device>("GetDevices");

onMounted(() => {
  fetchData();
});
</script>

<style scoped>
table {
  border-spacing: 0;
}

th,
td {
  border-collapse: collapse;
}
</style>
