<template>
  <div class="flex items-center justify-center min-h-screen bg-black">
    <div class="bg-iotGray p-8 rounded-lg shadow-lg w-full max-w-md">
      <h1 class="text-3xl font-mono text-iotGreen text-center mb-6">Login</h1>
      <form @submit.prevent="handleLogin" class="space-y-6">
        <!-- Username Field -->
        <div>
          <label
            for="username"
            class="block text-sm font-medium text-iotGreen mb-2"
          >
            Username
          </label>
          <input
            id="username"
            v-model="username"
            type="text"
            placeholder="Enter your username"
            class="w-full p-3 bg-iotBlack text-white rounded-md focus:outline-none focus:ring focus:ring-iotGreen"
          />
        </div>

        <!-- Password Field -->
        <div>
          <label
            for="password"
            class="block text-sm font-medium text-iotGreen mb-2"
          >
            Password
          </label>
          <input
            id="password"
            v-model="password"
            type="password"
            placeholder="Enter your password"
            class="w-full p-3 bg-iotBlack text-white rounded-md focus:outline-none focus:ring focus:ring-iotGreen"
          />
        </div>

        <!-- New Password Field -->
        <div>
          <label
            for="new-password"
            class="block text-sm font-medium text-iotGreen mb-2"
          >
            New Password (if required)
          </label>
          <input
            id="new-password"
            v-model="newPassword"
            type="password"
            placeholder="Enter a new password"
            class="w-full p-3 bg-iotBlack text-white rounded-md focus:outline-none focus:ring focus:ring-iotGreen"
          />
        </div>

        <!-- Submit Button -->
        <button
          type="submit"
          class="w-full bg-iotGreen hover:bg-iotGreenHover text-black font-bold py-3 rounded-md transition duration-300"
        >
          Login
        </button>
      </form>

      <!-- Redirect Message -->
      <p class="text-center text-sm text-iotGreen mt-6">
        Don’t have an account?
        <a href="/signup" class="text-iotGreenHover underline">Sign Up</a>
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue";
import { useRouter } from "vue-router";
import { login } from "../services/auth-service";

const username = ref("");
const password = ref("");
const newPassword = ref("");
const router = useRouter();

definePageMeta({
  layout: "clean",
});

const handleLogin = async () => {
  try {
    const idToken = await login(
      username.value,
      password.value,
      newPassword.value
    );

    // Save token to a cookie
    useCookie("authToken").value = idToken;

    // Redirect to the home page
    router.push("/");
  } catch (err) {
    console.error("Login failed:", err);
    if (err instanceof Error) {
      alert(err.message || "Login failed. Please try again.");
    } else {
      alert("Login failed. Please try again.");
    }
  }
};
</script>
