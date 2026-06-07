<template>
  <div class="dashboard">
    <div class="dashboard-header">
      <div class="header-left">
        <h2 class="header-title">{{ $t("route.overview") }}</h2>
        <p class="header-subtitle">Server monitoring & statistics</p>
      </div>
      <div class="header-right">
        <span class="badge badge-version">{{ dash.huiVersion || "-" }}</span>
        <span class="badge" :class="dash.running ? 'badge-on' : 'badge-off'">
          <span class="dot" :class="dash.running ? 'dot-green' : 'dot-red'"></span>
          {{ dash.running ? "Running" : "Stopped" }}
        </span>
      </div>
    </div>

    <div class="grid-3">
      <div class="card gauge-card" v-for="g in gauges" :key="g.label">
        <div class="gauge-wrap">
          <svg viewBox="0 0 100 100" class="gauge-svg">
            <circle cx="50" cy="50" r="42" fill="none" stroke="currentColor" stroke-width="6" opacity="0.08" />
            <circle cx="50" cy="50" r="42" fill="none" :stroke="g.color" stroke-width="6" stroke-linecap="round"
              :stroke-dasharray="g.circ" :stroke-dashoffset="g.off" transform="rotate(-90, 50, 50)" class="gauge-arc" />
          </svg>
          <div class="gauge-val" :style="{ color: g.color }">{{ Math.round(g.val) }}%</div>
        </div>
        <div class="gauge-label">{{ g.label }}</div>
        <div class="gauge-sub">{{ g.sub }}</div>
      </div>

    </div>

    <div class="grid-4">
      <div class="card stat-card">
        <div class="card-icon-box" style="background:rgba(99,102,241,0.1);color:#818cf8">
          <svg-icon icon-class="download" size="1.3em" />
        </div>
        <div class="card-body">
          <div class="card-label">Total Download</div>
          <div class="card-value">{{ formatBytes(dash.totalDownload) }}</div>
          <div v-if="trafficRate.download > 0" class="card-rate" style="color:#34d399">+{{ formatBytes(trafficRate.download) }}/s</div>
        </div>
      </div>
      <div class="card stat-card">
        <div class="card-icon-box" style="background:rgba(52,211,153,0.1);color:#34d399">
          <svg-icon icon-class="upload" size="1.3em" />
        </div>
        <div class="card-body">
          <div class="card-label">Total Upload</div>
          <div class="card-value">{{ formatBytes(dash.totalUpload) }}</div>
          <div v-if="trafficRate.upload > 0" class="card-rate" style="color:#fbbf24">+{{ formatBytes(trafficRate.upload) }}/s</div>
        </div>
      </div>
      <div class="card stat-card">
        <div class="card-icon-box" style="background:rgba(167,139,250,0.1);color:#a78bfa">
          <svg-icon icon-class="users" size="1.3em" />
        </div>
        <div class="card-body">
          <div class="card-label">Total Users</div>
          <div class="card-value">{{ dash.totalUsers }}</div>
          <div class="card-sub">Active accounts</div>
        </div>
      </div>
      <div class="card stat-card">
        <div class="card-icon-box" style="background:rgba(52,211,153,0.1);color:#34d399">
          <svg-icon icon-class="share" size="1.3em" />
        </div>
        <div class="card-body">
          <div class="card-label">Online</div>
          <div class="card-value">{{ dash.userTotal }}</div>
          <div class="card-sub">{{ dash.deviceTotal }} devices</div>
        </div>
      </div>
    </div>

    <div class="flex gap-4" style="display:flex;gap:16px;margin-bottom:24px">
      <div class="card" style="flex:1;min-width:0">
        <div class="card-header">Online Clients {{ onlineUsers.length > 0 ? `(${onlineUsers.length})` : '' }}</div>
        <div class="online-list" v-if="onlineUsers.length > 0">
          <div class="online-row" v-for="u in onlineUsers" :key="u.username">
            <span class="online-name">{{ u.username }}</span>
            <span class="online-devices">{{ u.deviceCount }} device{{ u.deviceCount > 1 ? 's' : '' }}</span>
            <span class="online-traffic">{{ formatBytes(u.download + u.upload) }}</span>
          </div>
        </div>
        <div v-else class="empty-state">
          <svg-icon icon-class="users" size="2em" style="opacity:0.2;margin-bottom:8px" />
          <span>No clients online</span>
        </div>
      </div>
      <div class="card" style="flex:1;min-width:0">
        <div class="card-header">Traffic Rate</div>
        <div class="rate-chart-wrap">
          <svg :viewBox="`0 0 ${rateHistory.length} 100`" class="rate-svg" v-if="rateHistory.length > 1">
            <polyline :points="rateDownloadPoints" fill="none" stroke="#818cf8" stroke-width="2" opacity="0.8" />
            <polyline :points="rateUploadPoints" fill="none" stroke="#34d399" stroke-width="2" opacity="0.8" />
          </svg>
          <div v-else class="empty-state">
            <span>Collecting data...</span>
          </div>
          <div class="rate-legend">
            <span><span class="legend-dot" style="background:#818cf8"></span> Download</span>
            <span><span class="legend-dot" style="background:#34d399"></span> Upload</span>
          </div>
        </div>
      </div>
    </div>

    <div class="grid-3">
      <div class="card info-card">
        <div class="card-header">Honest-UI</div>
        <div class="info-body">
          <div class="info-row"><span class="info-key">Version</span><span class="info-val">{{ dash.huiVersion || "-" }}</span></div>
          <div class="info-row"><span class="info-key">Status</span><span class="info-val" :style="{color:dash.running?'#34d399':'#ef4444'}">{{ dash.running ? "Running" : "Stopped" }}</span></div>
        </div>
      </div>
      <div class="card info-card">
        <div class="card-header">Hysteria2</div>
        <div class="info-body">
          <div class="info-row"><span class="info-key">Version</span><span class="info-val">{{ dash.version || "-" }}</span></div>
          <div class="info-row"><span class="info-key">Online</span><span class="info-val">{{ dash.userTotal }} users / {{ dash.deviceTotal }} devices</span></div>
        </div>
      </div>
      <div class="card info-card">
        <div class="card-header">Resources</div>
        <div class="info-body">
          <div class="info-row"><span class="info-key">CPU</span><span class="info-val">{{ Math.round(dash.cpuPercent) }}%</span></div>
          <div class="info-row"><span class="info-key">Memory</span><span class="info-val">{{ Math.round(dash.memPercent) }}%</span></div>
          <div class="info-row"><span class="info-key">Disk</span><span class="info-val">{{ Math.round(dash.diskPercent) }}%</span></div>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
export default { name: "OverviewIndex" }
</script>

<script setup lang="ts">
import { monitorDashboardApi, monitorOnlineUsersApi } from "@/api/monitor";
import { OnlineUserVo } from "@/api/monitor/types";
import { formatBytes } from "@/utils/byte";

const dash = reactive({
  huiVersion: "", cpuPercent: 0, memPercent: 0, diskPercent: 0,
  userTotal: 0, deviceTotal: 0, version: "", running: false,
  totalDownload: 0, totalUpload: 0, totalUsers: 0,
});

const onlineUsers = ref<OnlineUserVo[]>([]);

const trafficRate = reactive({ download: 0, upload: 0 });
const rateHistory = reactive<{ dl: number; ul: number }[]>([]);
const prevTraffic = reactive({ download: 0, upload: 0 });

const gaugeColors = ["#818cf8", "#34d399", "#fbbf24"];

const gauges = computed(() => [
  { label: "CPU", sub: "Processor", val: dash.cpuPercent, color: gaugeColors[0], circ: 2 * Math.PI * 42, off: 2 * Math.PI * 42 * (1 - (dash.cpuPercent ?? 0) / 100) },
  { label: "Memory", sub: "RAM", val: dash.memPercent, color: gaugeColors[1], circ: 2 * Math.PI * 42, off: 2 * Math.PI * 42 * (1 - (dash.memPercent ?? 0) / 100) },
  { label: "Disk", sub: "Storage", val: dash.diskPercent, color: gaugeColors[2], circ: 2 * Math.PI * 42, off: 2 * Math.PI * 42 * (1 - (dash.diskPercent ?? 0) / 100) },
]);

const rateDownloadPoints = computed(() =>
  rateHistory.map((p, i) => `${i},${100 - Math.min(p.dl / 1024 / 1024 * 50, 100)}`).join(" ")
);
const rateUploadPoints = computed(() =>
  rateHistory.map((p, i) => `${i},${100 - Math.min(p.ul / 1024 / 1024 * 50, 100)}`).join(" ")
);

let dlTimer: ReturnType<typeof setInterval> | null = null;
let ulTimer: ReturnType<typeof setInterval> | null = null;

function calcRate() {
  const dl = dash.totalDownload - prevTraffic.download;
  const ul = dash.totalUpload - prevTraffic.upload;
  trafficRate.download = dl;
  trafficRate.upload = ul;
  prevTraffic.download = dash.totalDownload;
  prevTraffic.upload = dash.totalUpload;
  rateHistory.push({ dl, ul });
  if (rateHistory.length > 60) rateHistory.shift();
}

const fetchDashboard = () => {
  monitorDashboardApi().then((res) => {
    Object.assign(dash, res.data);
    if (prevTraffic.download === 0 && prevTraffic.upload === 0) {
      prevTraffic.download = res.data.totalDownload;
      prevTraffic.upload = res.data.totalUpload;
    }
  }).catch(() => {});
};

const fetchOnlineUsers = () => {
  monitorOnlineUsersApi().then((res) => {
    onlineUsers.value = res.data;
  }).catch(() => {});
};

onMounted(() => {
  fetchDashboard();
  fetchOnlineUsers();
  dlTimer = setInterval(fetchDashboard, 2000);
  ulTimer = setInterval(calcRate, 2000);
  setInterval(fetchOnlineUsers, 5000);
});

onBeforeUnmount(() => {
  if (dlTimer) clearInterval(dlTimer);
  if (ulTimer) clearInterval(ulTimer);
});
</script>

<style lang="scss" scoped>
.dashboard { padding: 24px; }

.dashboard-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; }
.header-title { margin: 0 0 2px; font-size: 22px; font-weight: 700; color: var(--el-text-color-primary); }
.header-subtitle { margin: 0; font-size: 13px; color: var(--el-text-color-secondary); }
.header-right { display: flex; gap: 8px; }

.badge { display: inline-flex; align-items: center; gap: 5px; padding: 3px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; }
.badge-version { background: rgba(99,102,241,0.1); color: #818cf8; }
.badge-on { background: rgba(52,211,153,0.1); color: #34d399; }
.badge-off { background: rgba(239,68,68,0.1); color: #ef4444; }
.dot { width: 6px; height: 6px; border-radius: 50%; display: inline-block; }
.dot-green { background: #34d399; box-shadow: 0 0 6px rgba(52,211,153,0.5); }
.dot-red { background: #ef4444; box-shadow: 0 0 6px rgba(239,68,68,0.5); }

.grid-3, .grid-4 { display: grid; gap: 16px; margin-bottom: 24px; }
.grid-3 { grid-template-columns: repeat(3, 1fr); }
.grid-4 { grid-template-columns: repeat(4, 1fr); }

.card { border-radius: 14px; border: 1px solid var(--el-border-color-light); background: var(--el-bg-color-overlay); padding: 20px; transition: all 0.25s ease; }
.card:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(0,0,0,0.06); }
.card-header { font-size: 13px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; color: var(--el-text-color-secondary); margin-bottom: 14px; }
.card-icon-box { width: 44px; height: 44px; border-radius: 12px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.card-body { display: flex; flex-direction: column; min-width: 0; }
.card-label { font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; color: var(--el-text-color-secondary); margin-bottom: 2px; }
.card-value { font-size: 20px; font-weight: 700; color: var(--el-text-color-primary); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.card-sub { font-size: 11px; color: var(--el-text-color-placeholder); margin-top: 2px; }
.card-rate { font-size: 12px; font-weight: 600; margin-top: 2px; }

.gauge-card { display: flex; flex-direction: column; align-items: center; text-align: center; padding: 24px 16px 20px; }
.gauge-wrap { position: relative; width: 110px; height: 110px; margin-bottom: 10px; }
.gauge-svg { width: 110px; height: 110px; }
.gauge-arc { transition: stroke-dashoffset 0.5s ease; }
.gauge-val { position: absolute; top: 50%; left: 50%; transform: translate(-50%,-50%); font-size: 22px; font-weight: 800; }
.gauge-label { font-size: 14px; font-weight: 700; color: var(--el-text-color-primary); }
.gauge-sub { font-size: 11px; color: var(--el-text-color-placeholder); margin-top: 2px; }

.stat-card { display: flex; align-items: center; gap: 14px; }

.online-list { display: flex; flex-direction: column; gap: 6px; max-height: 240px; overflow-y: auto; }
.online-row { display: flex; align-items: center; gap: 8px; padding: 8px 10px; border-radius: 8px; background: var(--el-fill-color-light); font-size: 13px; }
.online-name { flex: 1; font-weight: 600; color: var(--el-text-color-primary); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.online-devices { font-size: 11px; color: var(--el-text-color-secondary); flex-shrink: 0; }
.online-traffic { font-size: 12px; font-weight: 600; color: var(--el-text-color-primary); flex-shrink: 0; }

.empty-state { display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 24px; color: var(--el-text-color-placeholder); font-size: 13px; }

.rate-chart-wrap { display: flex; flex-direction: column; gap: 10px; }
.rate-svg { width: 100%; height: 100px; background: var(--el-fill-color-light); border-radius: 8px; }
.rate-legend { display: flex; gap: 16px; font-size: 11px; color: var(--el-text-color-secondary); }
.legend-dot { width: 8px; height: 8px; border-radius: 50%; display: inline-block; margin-right: 4px; vertical-align: middle; }

.info-body { display: flex; flex-direction: column; gap: 10px; }
.info-row { display: flex; justify-content: space-between; align-items: center; }
.info-key { font-size: 12px; color: var(--el-text-color-secondary); }
.info-val { font-size: 13px; font-weight: 600; color: var(--el-text-color-primary); }

@media (max-width: 1100px) {
  .grid-4 { grid-template-columns: repeat(2, 1fr); }
}

@media (max-width: 900px) {
  .flex.gap-4 { flex-direction: column; }
}

@media (max-width: 768px) {
  .dashboard { padding: 16px; }
  .grid-3 { grid-template-columns: 1fr; }
  .grid-4 { grid-template-columns: 1fr 1fr; }
  .dashboard-header { flex-direction: column; align-items: flex-start; gap: 12px; }
}

@media (max-width: 480px) {
  .grid-4 { grid-template-columns: 1fr; }
}
</style>
