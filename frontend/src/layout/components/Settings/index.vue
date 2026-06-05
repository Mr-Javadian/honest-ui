<script setup lang="ts">
import { useSettingsStore } from "@/store/modules/settings";

import IconEpSunny from "~icons/ep/sunny";
import IconEpMoon from "~icons/ep/moon";

/**
 * Dark mode
 */
const settingsStore = useSettingsStore();
const isDark = useDark();
const toggleDark = () => useToggle(isDark);

/**
 * Toggle layout
 */
function changeLayout(layout: string) {
  settingsStore.changeSetting({ key: "layout", value: layout });
  window.document.body.setAttribute("layout", settingsStore.layout);
}

// Theme colors
const themeColors = ref<string[]>([
  "#409EFF",
  "#304156",
  "#11a983",
  "#13c2c2",
  "#6959CD",
  "#f5222d",
]);

/**
 * Toggle theme color
 */
function changeThemeColor(color: string) {
  settingsStore.changeSetting({ key: "themeColor", value: color });
  document.documentElement.style.setProperty(
    "--el-color-primary",
    settingsStore.themeColor
  );
}

onMounted(() => {
  window.document.body.setAttribute("layout", settingsStore.layout);
  document.documentElement.style.setProperty(
    "--el-color-primary",
    settingsStore.themeColor
  );
});
</script>

<template>
  <div class="settings-container">
    <h3 class="text-base font-bold">Project Configuration</h3>
    <el-divider>Theme</el-divider>

    <div class="flex justify-center" @click.stop>
      <el-switch
        v-model="isDark"
        @change="toggleDark"
        inline-prompt
        :active-icon="IconEpMoon"
        :inactive-icon="IconEpSunny"
        active-color="var(--el-fill-color-dark)"
        inactive-color="var(--el-color-primary)"
      />
    </div>

    <el-divider>Interface Settings</el-divider>
    <div class="py-[8px] flex justify-between">
      <span class="text-xs">Enable Tags-View</span>
      <el-switch v-model="settingsStore.tagsView" />
    </div>

    <div class="py-[8px] flex justify-between">
      <span class="text-xs">Fixed Header</span>
      <el-switch v-model="settingsStore.fixedHeader" />
    </div>

    <div class="py-[8px] flex justify-between">
      <span class="text-xs">Sidebar Logo</span>
      <el-switch v-model="settingsStore.sidebarLogo" />
    </div>

    <el-divider>Theme Color</el-divider>

    <ul class="w-full space-x-2 flex justify-center py-2">
      <li
        class="inline-block w-[30px] h-[30px] cursor-pointer"
        v-for="(color, index) in themeColors"
        :key="index"
        :style="{ background: color }"
        @click="changeThemeColor(color)"
      ></li>
    </ul>
  </div>
</template>

<style lang="scss" scoped>
.settings-container {
  padding: 16px;

  .layout {
    display: flex;
    flex-wrap: wrap;
    justify-content: space-around;
    width: 100%;
    height: 50px;

    &-item {
      position: relative;
      width: 18%;
      height: 45px;
      overflow: hidden;
      cursor: pointer;
      background: #f0f2f5;
      border-radius: 4px;
    }

    &-item.is-active {
      border: 2px solid var(--el-color-primary);
    }

    &-mix div:nth-child(1) {
      width: 100%;
      height: 30%;
      background: #1b2a47;
      box-shadow: 0 0 1px #888;
    }

    &-mix div:nth-child(2) {
      position: absolute;
      bottom: 0;
      left: 0;
      width: 30%;
      height: 70%;
      background: #1b2a47;
      box-shadow: 0 0 1px #888;
    }

    &-top div:nth-child(1) {
      width: 100%;
      height: 30%;
      background: #1b2a47;
      box-shadow: 0 0 1px #888;
    }

    &-left div:nth-child(1) {
      width: 30%;
      height: 100%;
      background: #1b2a47;
    }

    &-left div:nth-child(2) {
      position: absolute;
      top: 0;
      right: 0;
      width: 70%;
      height: 30%;
      background: #fff;
      box-shadow: 0 0 1px #888;
    }
  }
}
</style>
