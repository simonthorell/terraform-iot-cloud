<template>
  <aside class="w-48 p-6 bg-iotBlack text-iotGreen font-mono flex flex-col">
    <h2 class="text-3xl border-b border-iotGreen">Menu</h2>
    <ul class="mt-8 space-y-4 list-none">
      <li
        v-for="item in menuItems"
        :key="item"
        class="cursor-pointer text-2xl hover:text-iotGreenHover hover:font-bold"
        @click="handleMenuClick(item)"
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
import { useContent } from "~/composables/useContent";
import { logout } from "../../services/auth-service";

const { setContent, componentsMap } = useContent();

// Dynamically derive menu items from the keys of componentsMap
const menuItems = Object.keys(componentsMap) as Array<
  keyof typeof componentsMap
>;

const handleMenuClick = (item: keyof typeof componentsMap) => {
  setContent(item);
};

const handleLogout = async () => {
  try {
    await logout();
    // Clear local session data
    useCookie("authToken").value = null;
    // Redirect to login page
    window.location.href = "/login";
  } catch (err) {
    console.error("Logout failed:", err);
    const errorMessage =
      (err as Error).message || "Failed to log out. Please try again.";
    alert(errorMessage);
  }
};
</script>
