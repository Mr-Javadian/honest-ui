<script setup lang="ts">
import { storeToRefs } from "pinia";
import { useRoute, useRouter } from "vue-router";
import { useAppStore } from "@/store/modules/app";
import { useTagsViewStore } from "@/store/modules/tagsView";
import { useAccountStore } from "@/store/modules/account";

const appStore = useAppStore();
const tagsViewStore = useTagsViewStore();
const accountStore = useAccountStore();

const route = useRoute();
const router = useRouter();

const { device } = storeToRefs(appStore);

function toggleSideBar() {
  appStore.toggleSidebar(true);
}

const { isFullscreen, toggle } = useFullscreen();

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
  <div class="navbar modern-navbar">
    <div class="flex">
      <hamburger
        :is-active="appStore.sidebar.opened"
        @toggleClick="toggleSideBar"
      />
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

      <el-dropdown trigger="click">
        <div class="avatar-container">
          <img src="/src/assets/logo.png" />
          <i-ep-caret-bottom class="w-3 h-3" />
        </div>
        <template #dropdown>
          <el-dropdown-menu>
            <el-dropdown-item @click="logout">
              {{ $t("navbar.logout") }}
            </el-dropdown-item>
          </el-dropdown-menu>
        </template>
      </el-dropdown>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.navbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 56px;
  padding: 0 16px;
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

  .avatar-container {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 4px 8px;
    margin-left: 8px;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.2s ease;

    &:hover {
      background: var(--el-fill-color-light);
    }

    img {
      width: 32px;
      height: 32px;
      border-radius: 8px;
    }
  }
}
</style>
