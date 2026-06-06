<script setup lang="ts">
import { useRoute } from "vue-router";
import SidebarItem from "./SidebarItem.vue";
import Logo from "./Logo.vue";
import { useSettingsStore } from "@/store/modules/settings";
import { usePermissionStore } from "@/store/modules/permission";
import { useAppStore } from "@/store/modules/app";
import { storeToRefs } from "pinia";
import variables from "@/styles/variables.module.scss";

const settingsStore = useSettingsStore();
const permissionStore = usePermissionStore();
const appStore = useAppStore();
const { sidebarLogo } = storeToRefs(settingsStore);
const route = useRoute();
const isCollapsed = computed(() => !appStore.sidebar.opened);
</script>

<template>
  <div :class="{ 'has-logo': sidebarLogo }">
    <logo v-if="sidebarLogo" :collapse="isCollapsed" />
    <el-scrollbar>
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
    <div v-if="isCollapsed" class="sidebar-version-collapsed">v0.4.6</div>
  </div>
</template>

<style lang="scss">
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
