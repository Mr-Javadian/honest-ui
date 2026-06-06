<script lang="ts" setup>
import { useSettingsStore } from "@/store/modules/settings";

const settingsStore = useSettingsStore();

defineProps({
  collapse: { type: Boolean, required: true },
});

const logo = ref(new URL(`../../../assets/logo.png`, import.meta.url).href);
</script>

<template>
  <div class="sidebar-logo" :class="{ collapsed }">
    <router-link to="/" class="sidebar-logo-link">
      <img v-if="settingsStore.sidebarLogo" :src="logo" class="sidebar-logo-img" />
      <span v-if="!collapse" class="sidebar-logo-text">Honest-UI</span>
    </router-link>
  </div>
</template>

<style lang="scss" scoped>
.sidebar-logo {
  width: 100%;
  height: 56px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
  flex-shrink: 0;
}

.sidebar-logo-link {
  height: 100%;
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  text-decoration: none;
}

.sidebar-logo-img {
  width: 34px;
  height: 34px;
  flex-shrink: 0;
  border-radius: 8px;
}

.sidebar-logo-text {
  font-size: 17px;
  font-weight: 700;
  letter-spacing: 0.3px;
  background: linear-gradient(135deg, #818cf8 0%, #6366f1 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.collapsed {
  .sidebar-logo-link {
    gap: 0;
  }
}
</style>
