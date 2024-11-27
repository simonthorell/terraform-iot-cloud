<template>
  <div class="flex items-center justify-center min-h-screen bg-black">
    <div class="p-6 md:p-8 bg-iotGray rounded-lg shadow-lg w-full max-w-md">
      <h1 class="text-3xl font-mono text-iotGreen text-center mb-6">
        {{
          mode === "login"
            ? "Login"
            : mode === "newPassword"
            ? "Set New Password"
            : "Verify Your Account"
        }}
      </h1>
      <form @submit.prevent="handleSubmit" class="space-y-6">
        <!-- Username Field -->
        <div v-if="mode !== 'verifyCode'">
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
            :disabled="mode === 'newPassword'"
          />
        </div>

        <!-- Password Field -->
        <div v-if="mode === 'login'">
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

        <!-- New Password Fields -->
        <div v-if="mode === 'newPassword'">
          <div>
            <label
              for="new-password"
              class="block text-sm font-medium text-iotGreen mb-2"
            >
              New Password
            </label>
            <input
              id="new-password"
              v-model="newPassword"
              type="password"
              placeholder="Enter a new password"
              class="w-full p-3 bg-iotBlack text-white rounded-md focus:outline-none focus:ring focus:ring-iotGreen"
            />
          </div>
          <div class="mt-6">
            <label
              for="confirm-password"
              class="block text-sm font-medium text-iotGreen mb-2"
            >
              Confirm New Password
            </label>
            <input
              id="confirm-password"
              v-model="confirmPassword"
              type="password"
              placeholder="Confirm your new password"
              class="w-full p-3 bg-iotBlack text-white rounded-md focus:outline-none focus:ring focus:ring-iotGreen"
            />
          </div>
        </div>

        <!-- Verification Code Field -->
        <div v-if="mode === 'verifyCode'">
          <label
            for="verification-code"
            class="block text-sm font-medium text-iotGreen mb-2"
          >
            Verification Code
          </label>
          <input
            id="verification-code"
            v-model="verificationCode"
            type="text"
            placeholder="Enter the verification code sent to your email"
            class="w-full p-3 bg-iotBlack text-white rounded-md focus:outline-none focus:ring focus:ring-iotGreen"
          />
        </div>

        <!-- Submit Button -->
        <button
          type="submit"
          class="w-full bg-iotGreen hover:bg-iotGreenHover text-black font-bold py-3 rounded-md transition duration-300"
        >
          {{
            mode === "login"
              ? "Login"
              : mode === "newPassword"
              ? "Submit New Password"
              : "Verify Account"
          }}
        </button>
      </form>

      <!-- Redirect Message -->
      <p v-if="mode === 'login'" class="text-center text-sm text-iotGreen mt-6">
        Don’t have an account?
        <a href="/signup" class="text-iotGreenHover underline">Sign Up</a>
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue";
import { useRouter } from "vue-router";
import { login, confirmSignUp } from "../services/auth-service";

const username = ref("");
const password = ref("");
const newPassword = ref("");
const confirmPassword = ref("");
const verificationCode = ref("");
const mode = ref<"login" | "newPassword" | "verifyCode">("login");
const router = useRouter();

definePageMeta({
  layout: "clean",
});

const handleSubmit = async () => {
  try {
    if (mode.value === "login") {
      // Attempt to log in
      const idToken = await login(username.value, password.value);

      // Save token and redirect
      useCookie("authToken").value = idToken;
      router.push("/");
    } else if (mode.value === "newPassword") {
      // Ensure new password and confirmation match
      if (newPassword.value !== confirmPassword.value) {
        alert("Passwords do not match. Please try again.");
        return;
      }

      // Submit the new password
      const idToken = await login(
        username.value,
        password.value,
        newPassword.value
      );

      // Save token and redirect
      useCookie("authToken").value = idToken;
      router.push("/");
    } else if (mode.value === "verifyCode") {
      // Confirm the verification code
      await confirmSignUp(username.value, verificationCode.value);
      alert("Account verified successfully! Please log in.");
      mode.value = "login";
    }
  } catch (err: any) {
    console.error("Error:", err);
    if (
      err.message ===
      "New password is required, but no new password was provided."
    ) {
      // Switch to new password mode
      mode.value = "newPassword";
    } else if (err.message === "User is not confirmed.") {
      // Switch to verification code mode
      mode.value = "verifyCode";
    } else {
      alert(err.message || "An error occurred. Please try again.");
    }
  }
};
</script>
