<script setup lang="ts">
import { useRoute, useRouter } from "vue-router";
import Logo from "./Logo.vue";
import { useAppStore } from "@/store/modules/app";
import { useAccountStore } from "@/store/modules/account";
import { useTagsViewStore } from "@/store/modules/tagsView";
import variables from "@/styles/variables.module.scss";
import { APP_VERSION_PREFIXED } from "@/settings";
import { useAppTheme } from "@/hooks/useTheme";

import IEpDataAnalysis from "~icons/ep/data-analysis";
import IEpUser from "~icons/ep/user";
import IEpSetting from "~icons/ep/setting";
import IEpTools from "~icons/ep/tools";
import IEpChatDotSquare from "~icons/ep/chat-dot-square";
import IEpConnection from "~icons/ep/connection";
import IEpDocumentCopy from "~icons/ep/document-copy";
import IEpDocument from "~icons/ep/document";
import IEpTickets from "~icons/ep/tickets";

const iconMap: Record<string, any> = {
  "data-analysis": IEpDataAnalysis,
  user: IEpUser,
  setting: IEpSetting,
  tools: IEpTools,
  "chat-dot-square": IEpChatDotSquare,
  connection: IEpConnection,
  "document-copy": IEpDocumentCopy,
  document: IEpDocument,
  tickets: IEpTickets,
};

const appStore = useAppStore();
const accountStore = useAccountStore();
const tagsViewStore = useTagsViewStore();
const route = useRoute();
const router = useRouter();

const isCollapsed = computed(() => !appStore.sidebar.opened);

const { theme, cycleTheme } = useAppTheme();

const openKeys = ref<string[]>([]);

watch(() => route.path, (path) => {
  if (path.startsWith("/config/") || path.startsWith("/telegram/")) {
    openKeys.value = ["panel-settings"];
  } else if (path.startsWith("/log/")) {
    openKeys.value = ["logs"];
  } else {
    openKeys.value = [];
  }
}, { immediate: true });

const menuItems = [
  {
    title: "overview",
    icon: "data-analysis",
    path: "/overview/index",
  },
  {
    title: "clientsList",
    icon: "user",
    path: "/clients/list",
  },
  {
    title: "panelSettings",
    icon: "setting",
    key: "panel-settings",
    children: [
      { title: "configList", icon: "tools", path: "/config/list" },
      { title: "telegramList", icon: "chat-dot-square", path: "/telegram/list" },
    ],
  },
  {
    title: "hysteriaList",
    icon: "connection",
    path: "/hysteria/list",
  },
  {
    title: "log",
    icon: "document-copy",
    key: "logs",
    children: [
      { title: "logSystem", icon: "document", path: "/log/system" },
      { title: "logHysteria", icon: "tickets", path: "/log/hysteria" },
    ],
  },
];

function handleSelect(index: string) {
  router.push(index);
}

function toggleSidebar() {
  appStore.toggleSidebar(true);
}

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
  <div class="sidebar-flex">
    <Logo :collapse="isCollapsed" />

    <el-scrollbar class="sidebar-scrollbar">
      <el-menu
        :default-active="route.path"
        :collapse="isCollapsed"
        :background-color="variables.menuBg"
        :text-color="variables.menuText"
        :active-text-color="variables.menuActiveText"
        :collapse-transition="false"
        :unique-opened="true"
        :open-keys="isCollapsed ? [] : openKeys"
        mode="vertical"
        @select="handleSelect"
      >
        <template v-for="item in menuItems" :key="item.key || item.path">
          <el-sub-menu v-if="item.children" :index="item.key!">
            <template #title>
              <el-icon><component :is="iconMap[item.icon]" /></el-icon>
              <span>{{ $t(`route.${item.title}`) }}</span>
            </template>
            <el-menu-item
              v-for="child in item.children"
              :key="child.path"
              :index="child.path"
            >
              <el-icon><component :is="iconMap[child.icon]" /></el-icon>
              <template #title>{{ $t(`route.${child.title}`) }}</template>
            </el-menu-item>
          </el-sub-menu>
          <el-menu-item v-else :index="item.path">
            <el-icon><component :is="iconMap[item.icon]" /></el-icon>
            <template #title>{{ $t(`route.${item.title}`) }}</template>
          </el-menu-item>
        </template>
      </el-menu>
    </el-scrollbar>

    <div class="sidebar-bottom">
      <div class="sidebar-bottom-item" @click="cycleTheme">
        <el-tooltip
          :content="theme === 'light' ? 'Light' : theme === 'dark' ? 'Dark' : 'Ultra Dark'"
          :placement="isCollapsed ? 'right' : 'top'"
        >
          <el-icon :size="18">
            <i-ep-sunny v-if="theme === 'light'" />
            <i-ep-moon v-else-if="theme === 'dark'" />
            <i-ep-star-filled v-else />
          </el-icon>
        </el-tooltip>
        <span v-if="!isCollapsed" class="sidebar-bottom-label">{{ $t("navbar.theme") }}</span>
      </div>

      <div class="sidebar-bottom-item" @click="toggleSidebar">
        <el-tooltip
          :content="isCollapsed ? 'Expand' : 'Collapse'"
          :placement="isCollapsed ? 'right' : 'top'"
        >
          <el-icon :size="18">
            <i-ep-expand v-if="isCollapsed" />
            <i-ep-fold v-else />
          </el-icon>
        </el-tooltip>
        <span v-if="!isCollapsed" class="sidebar-bottom-label">{{ isCollapsed ? "Expand" : "Collapse" }}</span>
      </div>

      <div class="sidebar-bottom-item" @click="logout">
        <el-tooltip
          content="Logout"
          :placement="isCollapsed ? 'right' : 'top'"
        >
          <el-icon :size="18"><i-ep-switch-button /></el-icon>
        </el-tooltip>
        <span v-if="!isCollapsed" class="sidebar-bottom-label">{{ $t("navbar.logout") }}</span>
      </div>
    </div>

    <div class="sidebar-footer">
      <a
        v-if="!isCollapsed"
        href="https://github.com/Mr-Javadian/honest-ui"
        target="_blank"
        class="sidebar-version-link"
      >
        <el-icon><i-ep-link /></el-icon>
        <span>{{ APP_VERSION_PREFIXED }}</span>
      </a>
      <div v-else class="sidebar-version-collapsed">{{ APP_VERSION_PREFIXED }}</div>
    </div>
  </div>
</template>

<style lang="scss">
.sidebar-flex {
  display: flex;
  flex-direction: column;
  height: 100%;
}

.sidebar-scrollbar {
  flex: 1 1 auto;
  overflow-y: auto;
  min-height: 0;
}

.sidebar-bottom {
  flex: 0 0 auto;
  border-top: 1px solid rgba(255, 255, 255, 0.05);
  padding: 4px 0;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.sidebar-bottom-item {
  display: flex;
  align-items: center;
  gap: 10px;
  margin: 2px 8px;
  padding: 6px 12px;
  height: 36px;
  border-radius: 8px;
  cursor: pointer;
  color: var(--menuText, #cdd6f4);
  transition: all 0.2s ease;
  user-select: none;

  &:hover {
    background-color: var(--menuHover, #313244);
    color: var(--el-color-primary);
  }

  .el-icon {
    flex-shrink: 0;
  }
}

.sidebar-bottom-label {
  font-size: 13px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.hideSidebar {
  .sidebar-bottom-item {
    margin: 2px 6px;
    padding: 6px 0;
    justify-content: center;
  }
}

.sidebar-footer {
  flex: 0 0 auto;
  padding: 8px 12px 12px;
  border-top: 1px solid rgba(255, 255, 255, 0.05);
}

.sidebar-version-link {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  font-size: 12px;
  color: rgba(255, 255, 255, 0.3);
  text-decoration: none;
  transition: color 0.2s;

  &:hover {
    color: rgba(255, 255, 255, 0.6);
  }

  .el-icon {
    font-size: 14px;
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
