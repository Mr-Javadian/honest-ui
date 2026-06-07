<script setup lang="ts">
import { useI18n } from "vue-i18n";
import { restartServerApi, rebootServerApi } from "@/api/config";
import { restartHysteria2Api } from "@/api/hysteria2";

const { t } = useI18n();

const actions = [
  {
    label: "Restart Panel",
    icon: "refreshRight",
    desc: "This will restart the Honest-UI panel service. Active connections will be temporarily interrupted. The panel will come back online within a few seconds.",
    action: restartServerApi,
  },
  {
    label: "Restart Hysteria2",
    icon: "connection",
    desc: "This will restart the Hysteria2 proxy service. All current VPN connections will be disconnected. Users will need to reconnect.",
    action: restartHysteria2Api,
  },
  {
    label: "Restart Server",
    icon: "monitor",
    desc: "This will reboot the entire machine. All services including the panel and Hysteria2 will be stopped. Your SSH connection will be lost and the server will come back online after reboot.",
    action: rebootServerApi,
  },
];

function confirmAction(act: typeof actions[0]) {
  ElMessageBox.confirm(act.desc, act.label, {
    confirmButtonText: t("common.confirm"),
    cancelButtonText: t("common.cancel"),
    type: "warning",
    dangerouslyUseHTMLString: false,
  }).then(() => {
    act.action().then(() => {
      ElMessage.success(`${act.label} command sent successfully`);
    }).catch(() => {
      ElMessage.error(`Failed to execute ${act.label}`);
    });
  }).catch(() => {});
}
</script>

<template>
  <div class="navbar modern-navbar">
    <div class="navbar-left">
      <breadcrumb />
    </div>

    <div class="navbar-right">
      <button
        v-for="act in actions"
        :key="act.label"
        class="restart-btn"
        :class="act.icon"
        @click="confirmAction(act)"
      >
        <el-icon :size="16">
          <i-ep-refreshRight v-if="act.icon === 'refreshRight'" />
          <i-ep-connection v-else-if="act.icon === 'connection'" />
          <i-ep-monitor v-else />
        </el-icon>
        <span>{{ act.label }}</span>
      </button>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.navbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 56px;
  padding: 0 24px;
  background: var(--el-bg-color);
  border-bottom: 1px solid var(--el-border-color-light);
  backdrop-filter: blur(8px);
}

.navbar-left {
  display: flex;
  align-items: center;
}

.navbar-right {
  display: flex;
  align-items: center;
  gap: 8px;
}

.restart-btn {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 6px 14px;
  height: 34px;
  border: 1px solid var(--el-border-color-light);
  border-radius: 8px;
  background: var(--el-fill-color-blank);
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  white-space: nowrap;

  &.refreshRight {
    color: #f59e0b;
    &:hover { border-color: #f59e0b; background: rgba(245,158,11,0.08); }
  }
  &.connection {
    color: #3b82f6;
    &:hover { border-color: #3b82f6; background: rgba(59,130,246,0.08); }
  }
  &.monitor {
    color: #ef4444;
    &:hover { border-color: #ef4444; background: rgba(239,68,68,0.08); }
  }

  &:active { transform: scale(0.97); }
}
</style>
