<template>
  <component :is="currentComponent" />
</template>

<script setup lang="ts">
import { useContent } from "~/composables/useContent";
const { currentComponent } = useContent();
</script>
