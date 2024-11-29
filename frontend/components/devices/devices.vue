<template>
  <main class="flex-grow p-5 text-iotGreen font-mono">
    <h2 class="text-3xl mb-5">Devices</h2>
    <div class="bg-iotGray p-5 rounded-lg shadow-md shadow-iotGreen">
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
