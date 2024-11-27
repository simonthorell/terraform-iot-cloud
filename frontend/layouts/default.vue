<template>
  <div class="header">
    <SiteSidebar />
    <div class="main-content">
      <SiteHeader class="px-8 pt-8" />
      <SiteContent class="px-8 pb-8" />
    </div>
  </div>
</template>

<script setup lang="ts">
import SiteHeader from "~/components/site-header/header.vue";
import SiteSidebar from "~/components/site-sidebar/sidebar.vue";
import SiteContent from "~/components/site-content/content.vue";
</script>

<style scoped>
.header {
  display: flex;
  flex-direction: row;
  min-height: 100vh;
  background-color: black;
  margin: 0;
}

.main-content {
  display: flex;
  flex-direction: column;
  flex-grow: 1;
  padding: 0;
}
</style>
