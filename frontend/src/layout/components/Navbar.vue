<script setup lang="ts">
import { useI18n } from "vue-i18n";
import { restartServerApi } from "@/api/config";
import { restartHysteria2Api } from "@/api/hysteria2";

const { t } = useI18n();

const actions = [
  {
    label: "Restart Panel",
    icon: "refreshRight",
    desc: "This will restart the Honest-UI panel service. Active connections will be temporarily interrupted. The panel will come back online within a few seconds.",
    action: () => restartPanel(),
  },
  {
    label: "Restart Hysteria2",
    icon: "connection",
    desc: "This will restart the Hysteria2 proxy service. All current VPN connections will be disconnected. Users will need to reconnect.",
    action: () => restartHysteria(),
  },
  {
    label: "Restart Server",
    icon: "monitor",
    desc: "This will restart the entire server. All services including the panel and Hysteria2 will be stopped and the machine will reboot. This may take a minute or two.",
    action: () => restartServer(),
  },
];

function restartPanel() {
  return restartServerApi();
}

function restartHysteria() {
  return restartHysteria2Api();
}

function restartServer() {
  return restartServerApi();
}

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
  color: var(--el-text-color-secondary);
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  white-space: nowrap;

  &:hover {
    border-color: var(--el-color-primary);
    color: var(--el-color-primary);
    background: color-mix(in srgb, var(--el-color-primary) 8%, transparent);
  }

  &:active {
    transform: scale(0.97);
  }
}
</style>
