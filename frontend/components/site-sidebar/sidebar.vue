<!-- components/site-sidebar/sidebar.vue -->
<template>
  <aside class="w-48 p-6 bg-iotBlack text-iotGreen font-mono flex flex-col">
    <h2 class="text-3xl border-b border-iotGreen">Menu</h2>
    <ul class="mt-8 space-y-4 list-none">
      <li
        v-for="item in menuItems"
        :key="item"
        class="cursor-pointer text-2xl hover:text-iotGreenHover hover:font-bold"
      >
        {{ item }}
      </li>
    </ul>
  </aside>
</template>

<script setup lang="ts">
const menuItems = ref(["Dashboard", "Devices", "Settings"]);
</script>
