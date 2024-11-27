<template>
  <div class="flex items-center justify-center min-h-screen bg-black">
    <div class="p-6 md:p-8 bg-iotGray rounded-lg shadow-lg w-full max-w-md">
      <h1 class="text-3xl font-mono text-iotGreen text-center mb-6">Sign Up</h1>
      <form @submit.prevent="handleSignup" class="space-y-6">
        <!-- Username Field -->
        <div class="space-y-2">
          <label for="username" class="block text-sm font-medium text-iotGreen">
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

        <!-- Email Field -->
        <div class="space-y-2">
          <label for="email" class="block text-sm font-medium text-iotGreen">
            Email
          </label>
          <input
            id="email"
            v-model="email"
            type="email"
            placeholder="Enter your email"
            class="w-full p-3 bg-iotBlack text-white rounded-md focus:outline-none focus:ring focus:ring-iotGreen"
          />
        </div>

        <!-- Password Field -->
        <div class="space-y-2">
          <label for="password" class="block text-sm font-medium text-iotGreen">
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

        <!-- Confirm Password Field -->
        <div class="space-y-2">
          <label
            for="confirm-password"
            class="block text-sm font-medium text-iotGreen"
          >
            Confirm Password
          </label>
          <input
            id="confirm-password"
            v-model="confirmPassword"
            type="password"
            placeholder="Confirm your password"
            class="w-full p-3 bg-iotBlack text-white rounded-md focus:outline-none focus:ring focus:ring-iotGreen"
          />
        </div>

        <!-- Submit Button -->
        <button
          type="submit"
          class="w-full bg-iotGreen hover:bg-iotGreenHover text-black font-bold py-3 rounded-md transition duration-300"
        >
          Sign Up
        </button>
      </form>

      <!-- Redirect Message -->
      <p class="text-center text-sm text-iotGreen mt-6">
        Already have an account?
        <a href="/login" class="text-iotGreenHover underline">Log In</a>
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue";
import { useRouter } from "vue-router";
import { signUp } from "../services/auth-service"; // Signup logic in auth-service.ts

// Form fields
const username = ref("");
const email = ref("");
const password = ref("");
const confirmPassword = ref("");
const router = useRouter();

definePageMeta({
  layout: "clean",
});

const handleSignup = async () => {
  try {
    // Client-side validation
    if (password.value !== confirmPassword.value) {
      alert("Passwords do not match!");
      return;
    }

    if (!username.value || !email.value || !password.value) {
      alert("All fields are required.");
      return;
    }

    // Call signup service
    await signUp(username.value, email.value, password.value);

    // Redirect to login page after successful signup
    alert("Signup successful! Please check your email for verification.");
    router.push("/login");
  } catch (err) {
    console.error("Signup failed:", err);
    alert((err as any).message || "Signup failed. Please try again.");
  }
};
</script>
