<script setup lang="ts">
import { useRoute, useRouter } from "vue-router";
import SidebarItem from "./SidebarItem.vue";
import Logo from "./Logo.vue";
import { useSettingsStore } from "@/store/modules/settings";
import { usePermissionStore } from "@/store/modules/permission";
import { useAppStore } from "@/store/modules/app";
import { useAccountStore } from "@/store/modules/account";
import { useTagsViewStore } from "@/store/modules/tagsView";
import { storeToRefs } from "pinia";
import variables from "@/styles/variables.module.scss";
import { APP_VERSION_PREFIXED } from "@/settings";

import IconEpMoon from "~icons/ep/moon";
import IconEpSunny from "~icons/ep/sunny";

const settingsStore = useSettingsStore();
const permissionStore = usePermissionStore();
const appStore = useAppStore();
const accountStore = useAccountStore();
const tagsViewStore = useTagsViewStore();
const { sidebarLogo } = storeToRefs(settingsStore);
const route = useRoute();
const router = useRouter();
const isCollapsed = computed(() => !appStore.sidebar.opened);

const isDark = useDark();
const toggleDark = () => useToggle(isDark);

function logout() {
  ElMessageBox.confirm("Are you sure you want to log out?", "Prompt", {
    confirmButtonText: "Confirm",
    cancelButtonText: "Cancel",
    type: "warning",
  }).then(() => {
    accountStore
      .logout()
      .then(() => {
        tagsViewStore.delAllViews();
      })
      .then(() => {
        router.push(`/login?redirect=${route.fullPath}`);
      });
  });
}
</script>

<template>
  <div :class="{ 'has-logo': sidebarLogo }" class="sidebar-flex">
    <logo v-if="sidebarLogo" :collapse="isCollapsed" />

    <!-- Theme toggle -->
    <div v-if="!isCollapsed" class="sidebar-theme-row">
      <span class="sidebar-theme-label">Theme</span>
      <el-switch
        v-model="isDark"
        @change="toggleDark"
        inline-prompt
        :active-icon="IconEpMoon"
        :inactive-icon="IconEpSunny"
        active-color="var(--el-fill-color-dark)"
        inactive-color="var(--el-color-primary)"
        size="small"
      />
    </div>

    <el-scrollbar class="sidebar-scrollbar">
      <el-menu
        :default-active="route.path"
        :collapse="isCollapsed"
        :background-color="variables.menuBg"
        :text-color="variables.menuText"
        :active-text-color="variables.menuActiveText"
        :unique-opened="false"
        :collapse-transition="false"
        mode="vertical"
      >
        <sidebar-item
          v-for="routeItem in permissionStore.routes"
          :item="routeItem"
          :key="routeItem.path"
          :base-path="routeItem.path"
          :is-collapse="isCollapsed"
        />
      </el-menu>
    </el-scrollbar>

    <!-- Utility section: Logout -->
    <div class="sidebar-utility">
      <el-menu
        :collapse="isCollapsed"
        :background-color="variables.menuBg"
        :text-color="variables.menuText"
        :active-text-color="variables.menuActiveText"
        :collapse-transition="false"
        mode="vertical"
      >
        <el-menu-item @click="logout">
          <el-icon><i-ep-close /></el-icon>
          <template #title>{{ $t("navbar.logout") }}</template>
        </el-menu-item>
      </el-menu>
    </div>

    <!-- Version footer -->
    <div class="sidebar-footer">
      <a
        v-if="!isCollapsed"
        href="https://github.com/Mr-Javadian/honest-ui"
        target="_blank"
        class="sidebar-version-link"
      >
        <el-icon><i-ep-share /></el-icon>
        <span>{{ APP_VERSION_PREFIXED }}</span>
      </a>
    </div>

    <div v-if="isCollapsed" class="sidebar-version-collapsed">{{ APP_VERSION_PREFIXED }}</div>
  </div>
</template>

<style lang="scss">
.sidebar-flex {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.sidebar-theme-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 8px 16px;
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
}

.sidebar-theme-label {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.45);
  letter-spacing: 0.3px;
}

.sidebar-scrollbar {
  flex: 1 1 auto;
  overflow-y: auto;
  min-height: 0;
}

.has-logo .sidebar-scrollbar {
  height: auto !important;
}

.sidebar-utility {
  flex: 0 0 auto;
  border-top: 1px solid rgba(255, 255, 255, 0.05);
}

.sidebar-utility .el-menu {
  padding: 4px 0;
}

.sidebar-utility .el-menu-item {
  margin: 2px 12px;
  border-radius: 10px;
}

.sidebar-footer {
  flex: 0 0 auto;
  padding: 8px 16px 12px;
  border-top: 1px solid rgba(255, 255, 255, 0.05);
}

.sidebar-version-link {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 12px;
  color: rgba(255, 255, 255, 0.3);
  text-decoration: none;
  transition: color 0.2s;

  &:hover {
    color: rgba(255, 255, 255, 0.6);
  }
}

.sidebar-version-collapsed {
  position: absolute;
  bottom: 8px;
  left: 50%;
  transform: translateX(-50%);
  font-size: 9px;
  color: rgba(255, 255, 255, 0.2);
  letter-spacing: 0.3px;
  white-space: nowrap;
}
</style>
