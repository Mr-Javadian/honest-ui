<script setup lang="ts">
</script>

<template>
  <section class="app-main">
    <router-view v-slot="{ Component, route }">
      <transition name="router-fade" mode="out-in">
        <component :is="Component" :key="route.fullPath" />
      </transition>
    </router-view>
  </section>
</template>

<style lang="scss" scoped>
.app-main {
  position: relative;
  width: 100%;
  min-height: calc(100vh - 56px);
  overflow: hidden;
  background-color: var(--el-bg-color-page);
}

.fixed-header + .app-main {
  padding-top: 56px;
}
</style>
