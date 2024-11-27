<!-- components/site-sidebar/sidebar.vue -->
<template>
  <aside class="w-48 p-6 bg-iotBlack text-iotGreen font-mono flex flex-col">
    <h2 class="text-3xl border-b border-iotGreen">Menu</h2>
    <ul class="mt-8 space-y-4 list-none">
      <!-- Menu Items -->
      <li
        v-for="item in menuItems"
        :key="item"
        class="cursor-pointer text-2xl hover:text-iotGreenHover hover:font-bold"
      >
        {{ item }}
      </li>
    </ul>
    <!-- Logout Button -->
    <button
      @click="handleLogout"
      class="mt-auto border border-iotGreen text-iotGreen text-2xl font-bold py-2 px-4 rounded-md hover:bg-iotGreen hover:text-black transition duration-300"
    >
      Logout
    </button>
  </aside>
</template>

<script setup lang="ts">
import { useRouter } from "#app";
const menuItems = ref(["Dashboard", "Devices", "Settings"]);
const router = useRouter();

const handleLogout = () => {
  // Remove the auth token from cookies
  useCookie("authToken").value = null;

  // Redirect to the login page
  router.push("/login");
};
</script>
