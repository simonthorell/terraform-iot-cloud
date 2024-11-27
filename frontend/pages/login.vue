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
const username = ref("");
const password = ref("");
const router = useRouter();

definePageMeta({
  layout: "clean",
});

const handleLogin = () => {
  // Mock authentication
  if (username.value === "admin" && password.value === "password") {
    // Save token to cookie
    useCookie("authToken").value = "mock_token";
    // alert("Login successful!");
    router.push("/");
  } else {
    alert("Invalid credentials. Please try again.");
  }
};
</script>
