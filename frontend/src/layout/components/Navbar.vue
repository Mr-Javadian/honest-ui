<script setup lang="ts">
import { storeToRefs } from "pinia";
import { useAppStore } from "@/store/modules/app";

const appStore = useAppStore();

const { device } = storeToRefs(appStore);

const { isFullscreen, toggle } = useFullscreen();
</script>

<template>
  <div class="navbar modern-navbar">
    <div class="flex">
      <breadcrumb />
    </div>

    <div class="flex">
      <div class="setting-container" v-if="device !== 'mobile'">
        <div class="setting-item" @click="toggle">
          <svg-icon
            :icon-class="isFullscreen ? 'exit-fullscreen' : 'fullscreen'"
          />
        </div>
        <el-tooltip content="Layout Size" effect="dark" placement="bottom">
          <size-select class="setting-item" />
        </el-tooltip>
        <lang-select class="setting-item" />
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.navbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 56px;
  padding: 0 20px;
  background-color: var(--el-bg-color);
  border-bottom: 1px solid var(--el-border-color-light);
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.04);

  .setting-container {
    display: flex;
    align-items: center;
    gap: 4px;

    .setting-item {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      width: 32px;
      height: 32px;
      border-radius: 8px;
      color: var(--el-text-color-secondary);
      cursor: pointer;
      transition: all 0.2s ease;

      &:hover {
        background: var(--el-fill-color-light);
        color: var(--el-text-color-primary);
      }
    }
  }
}
</style>
