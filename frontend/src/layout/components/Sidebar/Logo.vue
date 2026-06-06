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
      <div v-if="!collapse" class="sidebar-logo-text-wrap">
        <span class="sidebar-logo-text">Honest-UI</span>
      </div>
    </router-link>
  </div>
</template>

<style lang="scss" scoped>
.sidebar-logo {
  width: 100%;
  height: 64px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);

  &.collapsed {
    .sidebar-logo-link { padding: 0; justify-content: center; }
  }
}

.sidebar-logo-link {
  height: 100%;
  width: 100%;
  display: flex;
  align-items: center;
  padding: 0 16px;
  text-decoration: none;
  gap: 12px;
}

.sidebar-logo-img {
  width: 40px;
  height: 40px;
  flex-shrink: 0;
  border-radius: 10px;
}

.sidebar-logo-text-wrap {
  display: flex;
  flex-direction: column;
  line-height: 1.2;
}

.sidebar-logo-text {
  font-size: 20px;
  font-weight: 800;
  letter-spacing: 0.5px;
  background: linear-gradient(135deg, #818cf8 0%, #6366f1 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}
</style>
