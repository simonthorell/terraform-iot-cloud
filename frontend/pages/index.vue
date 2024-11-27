<template>
  <div>
    <h1 class="text-3xl text-iotGreen">Welcome to the Dashboard</h1>
  </div>
</template>

<script setup>
definePageMeta({
  middleware: "auth",
});
</script>
