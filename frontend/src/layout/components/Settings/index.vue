<script setup lang="ts">
import { useSettingsStore } from "@/store/modules/settings";
import { useAppTheme } from "@/hooks/useTheme";

const settingsStore = useSettingsStore();
const { theme, cycleTheme } = useAppTheme();

function changeLayout(layout: string) {
  settingsStore.changeSetting({ key: "layout", value: layout });
  window.document.body.setAttribute("layout", settingsStore.layout);
}

const themeColors = ref<string[]>([
  "#409EFF",
  "#304156",
  "#11a983",
  "#13c2c2",
  "#6959CD",
  "#f5222d",
]);

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

    <div class="flex justify-center items-center gap-3" @click.stop>
      <el-tooltip
        content="Light"
        placement="top"
      >
        <button
          class="theme-cycle-btn"
          :class="{ active: theme === 'light' }"
          @click="theme !== 'light' && cycleTheme()"
        >
          <i-ep-sunny />
        </button>
      </el-tooltip>
      <el-tooltip
        content="Dark"
        placement="top"
      >
        <button
          class="theme-cycle-btn"
          :class="{ active: theme === 'dark' }"
          @click="theme !== 'dark' && cycleTheme()"
        >
          <i-ep-moon />
        </button>
      </el-tooltip>
      <el-tooltip
        content="Ultra Dark"
        placement="top"
      >
        <button
          class="theme-cycle-btn"
          :class="{ active: theme === 'ultra-dark' }"
          @click="theme !== 'ultra-dark' && cycleTheme()"
        >
          <i-ep-moon-filled />
        </button>
      </el-tooltip>
    </div>

    <el-divider>Interface Settings</el-divider>

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

  .theme-cycle-btn {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    border: 2px solid transparent;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    background: var(--el-fill-color-light);
    color: var(--el-text-color-secondary);
    font-size: 18px;
    transition: all 0.2s ease;

    &:hover {
      background: var(--el-fill-color);
      color: var(--el-color-primary);
    }

    &.active {
      border-color: var(--el-color-primary);
      color: var(--el-color-primary);
      background: color-mix(in srgb, var(--el-color-primary) 15%, transparent);
    }
  }
}
</style>
