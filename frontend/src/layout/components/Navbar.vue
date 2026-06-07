<script setup lang="ts">
import { useI18n } from "vue-i18n";
import { restartServerApi, rebootServerApi } from "@/api/config";
import { restartHysteria2Api } from "@/api/hysteria2";
import { monitorDashboardApi } from "@/api/monitor";

const { t } = useI18n();

const now = ref(new Date());
const uptime = ref(0);
let uptimeInterval: ReturnType<typeof setInterval> | null = null;
let clockInterval: ReturnType<typeof setInterval> | null = null;
let syncInterval: ReturnType<typeof setInterval> | null = null;

function formatUptime(seconds: number): string {
  const d = Math.floor(seconds / 86400);
  const h = Math.floor((seconds % 86400) / 3600);
  const m = Math.floor((seconds % 3600) / 60);
  const s = seconds % 60;
  const parts: string[] = [];
  if (d > 0) parts.push(`${d}d`);
  if (h > 0) parts.push(`${h}h`);
  if (m > 0) parts.push(`${m}m`);
  parts.push(`${s}s`);
  return parts.join(" ");
}

function formatDateTime(date: Date): { dateStr: string; timeStr: string } {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  const hours = String(date.getHours()).padStart(2, "0");
  const mins = String(date.getMinutes()).padStart(2, "0");
  const secs = String(date.getSeconds()).padStart(2, "0");
  return {
    dateStr: `${year}-${month}-${day}`,
    timeStr: `${hours}:${mins}:${secs}`,
  };
}

const dateTime = computed(() => formatDateTime(now.value));

async function fetchUptime() {
  try {
    const { data } = await monitorDashboardApi();
    uptime.value = data.uptime || 0;
  } catch {}
}

onMounted(async () => {
  await fetchUptime();
  uptimeInterval = setInterval(() => { uptime.value++; }, 1000);
  clockInterval = setInterval(() => { now.value = new Date(); }, 1000);
  syncInterval = setInterval(fetchUptime, 30000);
});

onUnmounted(() => {
  if (uptimeInterval) clearInterval(uptimeInterval);
  if (clockInterval) clearInterval(clockInterval);
  if (syncInterval) clearInterval(syncInterval);
});

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
      <div class="header-meta">
        <div class="server-time">
          <span class="time-value">{{ dateTime.timeStr }}</span>
          <span class="date-value">{{ dateTime.dateStr }}</span>
        </div>
        <div class="server-uptime">
          <span class="uptime-label">{{ t("navbar.uptime") || "Uptime" }}:</span>
          <span class="uptime-value">{{ formatUptime(uptime) }}</span>
        </div>
      </div>
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
  gap: 20px;
  flex-shrink: 0;
  min-width: 0;
}

.header-meta {
  display: flex;
  align-items: center;
  gap: 16px;
  padding-left: 16px;
  border-left: 1px solid var(--el-border-color-light);
}

.server-time {
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 13px;

  .time-value {
    font-weight: 600;
    color: var(--el-text-color-primary);
    font-variant-numeric: tabular-nums;
    letter-spacing: 0.5px;
  }

  .date-value {
    color: var(--el-text-color-placeholder);
    font-size: 12px;
  }
}

.server-uptime {
  display: flex;
  align-items: center;
  gap: 4px;
  font-size: 12px;
  color: var(--el-text-color-secondary);

  .uptime-label {
    color: var(--el-text-color-placeholder);
  }

  .uptime-value {
    font-weight: 500;
    color: var(--el-color-success);
    font-variant-numeric: tabular-nums;
  }
}

.navbar-right {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-shrink: 0;
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
