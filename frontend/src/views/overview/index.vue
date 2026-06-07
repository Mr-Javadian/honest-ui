<template>
  <div class="dashboard">
    <div class="dashboard-header">
      <div class="header-left">
        <h2 class="header-title">{{ $t("route.overview") }}</h2>
        <p class="header-subtitle">{{ $t("info.greeting2") }}{{ accountStore.username }}!</p>
      </div>
      <div class="header-right">
        <span class="version-badge">{{ dash.huiVersion || "-" }}</span>
        <el-tag v-if="dash.running" type="success" effect="dark" size="small">{{ $t("monitor.hysteria2RunningTrue") }}</el-tag>
        <el-tag v-else type="danger" effect="dark" size="small">{{ $t("monitor.hysteria2RunningFalse") }}</el-tag>
      </div>
    </div>

    <div class="gauge-row">
      <div class="gauge-card" v-for="g in gauges" :key="g.label">
        <svg viewBox="0 0 120 120" class="gauge-svg">
          <circle cx="60" cy="60" r="50" fill="none" stroke="currentColor" stroke-width="8" opacity="0.08" />
          <circle cx="60" cy="60" r="50" fill="none" :stroke="g.color" stroke-width="8" stroke-linecap="round"
            :stroke-dasharray="g.circumference" :stroke-dashoffset="g.offset" transform="rotate(-90, 60, 60)"
            class="gauge-arc" />
        </svg>
        <div class="gauge-value" :style="{ color: g.color }">{{ Math.round(g.value) }}%</div>
        <div class="gauge-label">{{ g.label }}</div>
      </div>
    </div>

    <div class="stats-grid">
      <div class="stat-card">
        <div class="stat-icon" style="background:rgba(99,102,241,0.1);color:#818cf8">
          <svg-icon icon-class="download" size="1.3em" />
        </div>
        <div class="stat-body">
          <span class="stat-label">{{ $t("account.download") }}</span>
          <span class="stat-value">{{ formatBytes(dash.totalDownload) }}</span>
          <span class="stat-desc">Total across all users</span>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon" style="background:rgba(52,211,153,0.1);color:#34d399">
          <svg-icon icon-class="upload" size="1.3em" />
        </div>
        <div class="stat-body">
          <span class="stat-label">{{ $t("account.upload") }}</span>
          <span class="stat-value">{{ formatBytes(dash.totalUpload) }}</span>
          <span class="stat-desc">Total across all users</span>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon" style="background:rgba(167,139,250,0.1);color:#a78bfa">
          <svg-icon icon-class="users" size="1.3em" />
        </div>
        <div class="stat-body">
          <span class="stat-label">Total Users</span>
          <span class="stat-value">{{ dash.totalUsers }}</span>
          <span class="stat-desc">Active client accounts</span>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon" style="background:rgba(251,191,36,0.1);color:#fbbf24">
          <svg-icon icon-class="share" size="1.3em" />
        </div>
        <div class="stat-body">
          <span class="stat-label">{{ $t("monitor.hysteria2UserTotal") }}</span>
          <span class="stat-value">{{ dash.userTotal }}</span>
          <span class="stat-desc">Currently connected</span>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon" style="background:rgba(245,158,11,0.1);color:#f59e0b">
          <svg-icon icon-class="size" size="1.3em" />
        </div>
        <div class="stat-body">
          <span class="stat-label">{{ $t("monitor.hysteria2DeviceTotal") }}</span>
          <span class="stat-value">{{ dash.deviceTotal }}</span>
          <span class="stat-desc">Devices online</span>
        </div>
      </div>
    </div>

    <div class="info-row">
      <div class="info-card">
        <span class="info-label">{{ $t("monitor.huiVersion") }}</span>
        <span class="info-value">{{ dash.huiVersion || "-" }}</span>
      </div>
      <div class="info-card">
        <span class="info-label">{{ $t("monitor.hysteria2Version") }}</span>
        <span class="info-value">{{ dash.version || "-" }}</span>
      </div>
      <div class="info-card">
        <span class="info-label">{{ $t("monitor.hysteria2Running") }}</span>
        <span class="info-value">
          <span class="status-dot" :class="dash.running ? 'dot-on' : 'dot-off'"></span>
          {{ dash.running ? $t("monitor.hysteria2RunningTrue") : $t("monitor.hysteria2RunningFalse") }}
        </span>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
export default { name: "OverviewIndex" }
</script>

<script setup lang="ts">
import { monitorDashboardApi } from "@/api/monitor";
import { useAccountStore } from "@/store/modules/account";
import { formatBytes } from "@/utils/byte";

const accountStore = useAccountStore();

const dash = reactive({
  huiVersion: "",
  cpuPercent: 0,
  memPercent: 0,
  diskPercent: 0,
  userTotal: 0,
  deviceTotal: 0,
  version: "",
  running: false,
  totalDownload: 0,
  totalUpload: 0,
  totalUsers: 0,
});

const gaugeColors = ["#818cf8", "#34d399", "#fbbf24"];

const gauges = computed(() => [
  {
    label: "CPU",
    value: dash.cpuPercent,
    color: gaugeColors[0],
    circumference: 2 * Math.PI * 50,
    offset: 2 * Math.PI * 50 * (1 - (dash.cpuPercent ?? 0) / 100),
  },
  {
    label: "Memory",
    value: dash.memPercent,
    color: gaugeColors[1],
    circumference: 2 * Math.PI * 50,
    offset: 2 * Math.PI * 50 * (1 - (dash.memPercent ?? 0) / 100),
  },
  {
    label: "Disk",
    value: dash.diskPercent,
    color: gaugeColors[2],
    circumference: 2 * Math.PI * 50,
    offset: 2 * Math.PI * 50 * (1 - (dash.diskPercent ?? 0) / 100),
  },
]);

let pollTimer: ReturnType<typeof setInterval> | null = null;

const fetchDashboard = () => {
  monitorDashboardApi().then((res) => {
    Object.assign(dash, res.data);
  }).catch(() => {});
};

onMounted(() => {
  fetchDashboard();
  pollTimer = setInterval(fetchDashboard, 5000);
});

onBeforeUnmount(() => {
  if (pollTimer) clearInterval(pollTimer);
});
</script>

<style lang="scss" scoped>
.dashboard {
  padding: 24px;
  max-width: 1200px;
  margin: 0 auto;
}

.dashboard-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 28px;
}

.header-left {
  .header-title {
    margin: 0 0 4px;
    font-size: 22px;
    font-weight: 700;
    color: var(--el-text-color-primary);
  }
  .header-subtitle {
    margin: 0;
    font-size: 14px;
    color: var(--el-text-color-secondary);
  }
}

.header-right {
  display: flex;
  align-items: center;
  gap: 10px;
}

.version-badge {
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
  background: rgba(99, 102, 241, 0.1);
  color: #818cf8;
}

.gauge-row {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
  margin-bottom: 28px;
}

.gauge-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding: 24px 16px 20px;
  border-radius: 16px;
  border: 1px solid var(--el-border-color-light);
  background: var(--el-bg-color-overlay);
  transition: all 0.25s ease;
  &:hover {
    transform: translateY(-3px);
    box-shadow: 0 8px 28px rgba(0, 0, 0, 0.1);
  }
}

.gauge-svg {
  width: 120px;
  height: 120px;
  margin-bottom: 8px;
}

.gauge-arc {
  transition: stroke-dashoffset 0.6s ease;
}

.gauge-value {
  font-size: 26px;
  font-weight: 800;
  line-height: 1;
  margin-bottom: 4px;
  transition: color 0.3s ease;
}

.gauge-label {
  font-size: 13px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 1px;
  color: var(--el-text-color-secondary);
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}

.stat-card {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 18px 20px;
  border-radius: 14px;
  border: 1px solid var(--el-border-color-light);
  background: var(--el-bg-color-overlay);
  transition: all 0.25s ease;
  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(0, 0, 0, 0.08);
  }
}

.stat-icon {
  width: 42px;
  height: 42px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.stat-body {
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.stat-label {
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  color: var(--el-text-color-secondary);
  margin-bottom: 2px;
}

.stat-value {
  font-size: 18px;
  font-weight: 700;
  color: var(--el-text-color-primary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.stat-desc {
  font-size: 11px;
  color: var(--el-text-color-placeholder);
  margin-top: 1px;
}

.info-row {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}

.info-card {
  display: flex;
  flex-direction: column;
  gap: 6px;
  padding: 16px 20px;
  border-radius: 12px;
  border: 1px solid var(--el-border-color-light);
  background: var(--el-bg-color-overlay);
}

.info-label {
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  color: var(--el-text-color-secondary);
}

.info-value {
  font-size: 15px;
  font-weight: 700;
  color: var(--el-text-color-primary);
  display: flex;
  align-items: center;
  gap: 6px;
}

.status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  display: inline-block;
  &.dot-on {
    background: #34d399;
    box-shadow: 0 0 6px rgba(52, 211, 153, 0.6);
  }
  &.dot-off {
    background: #ef4444;
    box-shadow: 0 0 6px rgba(239, 68, 68, 0.6);
  }
}

@media (max-width: 768px) {
  .dashboard { padding: 16px; }
  .gauge-row { grid-template-columns: 1fr; }
  .stats-grid { grid-template-columns: 1fr 1fr; }
  .info-row { grid-template-columns: 1fr; }
}
</style>
