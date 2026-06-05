<template>
  <div class="dashboard-container">
    <div class="monitor-grid">
      <div class="monitor-card version-card">
        <div class="card-accent"></div>
        <div class="card-icon">
          <svg-icon icon-class="honestui" size="1.4em" />
        </div>
        <div class="card-body">
          <span class="card-label">{{ $t("monitor.huiVersion") }}</span>
          <span class="card-value">{{ systemMonitor.huiVersion || "-" }}</span>
        </div>
      </div>

      <div class="monitor-card cpu-card">
        <div class="card-accent"></div>
        <div class="card-icon">
          <svg-icon icon-class="setting" size="1.4em" />
        </div>
        <div class="card-body">
          <span class="card-label">{{ $t("monitor.cpuPercent") }}</span>
          <div class="card-progress-row">
            <span class="card-value card-value--pct">{{ systemMonitor.cpuPercent != null ? systemMonitor.cpuPercent + "%" : "-" }}</span>
            <el-progress
              v-if="systemMonitor.cpuPercent != null"
              :percentage="Math.round(systemMonitor.cpuPercent)"
              :stroke-width="6"
              :show-text="false"
              color="#818cf8"
              class="monitor-progress"
            />
          </div>
        </div>
      </div>

      <div class="monitor-card mem-card">
        <div class="card-accent"></div>
        <div class="card-icon">
          <svg-icon icon-class="size" size="1.4em" />
        </div>
        <div class="card-body">
          <span class="card-label">{{ $t("monitor.memPercent") }}</span>
          <div class="card-progress-row">
            <span class="card-value card-value--pct">{{ systemMonitor.memPercent != null ? systemMonitor.memPercent + "%" : "-" }}</span>
            <el-progress
              v-if="systemMonitor.memPercent != null"
              :percentage="Math.round(systemMonitor.memPercent)"
              :stroke-width="6"
              :show-text="false"
              color="#34d399"
              class="monitor-progress"
            />
          </div>
        </div>
      </div>

      <div class="monitor-card disk-card">
        <div class="card-accent"></div>
        <div class="card-icon">
          <svg-icon icon-class="download" size="1.4em" />
        </div>
        <div class="card-body">
          <span class="card-label">{{ $t("monitor.diskPercent") }}</span>
          <div class="card-progress-row">
            <span class="card-value card-value--pct">{{ systemMonitor.diskPercent != null ? systemMonitor.diskPercent + "%" : "-" }}</span>
            <el-progress
              v-if="systemMonitor.diskPercent != null"
              :percentage="Math.round(systemMonitor.diskPercent)"
              :stroke-width="6"
              :show-text="false"
              color="#fbbf24"
              class="monitor-progress"
            />
          </div>
        </div>
      </div>

      <div class="monitor-card hv-card">
        <div class="card-accent"></div>
        <div class="card-icon">
          <svg-icon icon-class="hysteria" size="1.4em" />
        </div>
        <div class="card-body">
          <span class="card-label">{{ $t("monitor.hysteria2Version") }}</span>
          <span class="card-value">{{ hysteria2Monitor.version || "-" }}</span>
        </div>
      </div>

      <div class="monitor-card running-card">
        <div class="card-accent"></div>
        <div class="card-icon">
          <svg-icon icon-class="report" size="1.4em" />
        </div>
        <div class="card-body">
          <span class="card-label">{{ $t("monitor.hysteria2Running") }}</span>
          <span
            class="card-value"
            :class="hysteria2Monitor.running === true ? 'color-green' : hysteria2Monitor.running === false ? 'color-red' : ''"
          >
            {{ hysteria2Monitor.running === undefined ? "-" : hysteria2Monitor.running ? $t("monitor.hysteria2RunningTrue") : $t("monitor.hysteria2RunningFalse") }}
          </span>
        </div>
      </div>

      <div class="monitor-card users-card">
        <div class="card-accent"></div>
        <div class="card-icon">
          <svg-icon icon-class="users" size="1.4em" />
        </div>
        <div class="card-body">
          <span class="card-label">{{ $t("monitor.hysteria2UserTotal") }}</span>
          <span class="card-value">{{ hysteria2Monitor.userTotal }}</span>
        </div>
      </div>

      <div class="monitor-card device-card">
        <div class="card-accent"></div>
        <div class="card-icon">
          <svg-icon icon-class="share" size="1.4em" />
        </div>
        <div class="card-body">
          <span class="card-label">{{ $t("monitor.hysteria2DeviceTotal") }}</span>
          <span class="card-value">{{ hysteria2Monitor.deviceTotal }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts">
export default {
  name: "MonitorSystem",
};
</script>

<script setup lang="ts">
import { monitorHysteria2Api, monitorSystemApi } from "@/api/monitor";

const state = reactive({
  systemMonitor: {
    huiVersion: "",
    cpuPercent: 0,
    memPercent: 0,
    diskPercent: 0,
  },
  hysteria2Monitor: {
    userTotal: 0,
    deviceTotal: 0,
    version: undefined,
    running: undefined,
  },
});

const { systemMonitor, hysteria2Monitor } = toRefs(state);

const setMonitor = () => {
  monitorSystemApi().then((response) => {
    const { data } = response;
    Object.assign(state.systemMonitor, data);
  });
  monitorHysteria2Api().then((response) => {
    const { data } = response;
    Object.assign(state.hysteria2Monitor, data);
  });
};

onMounted(() => {
  setMonitor();
});
</script>

<style lang="scss" scoped>
.dashboard-container {
  padding: 24px;
}

.monitor-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 16px;
}

.monitor-card {
  position: relative;
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px 24px;
  border-radius: 14px;
  border: 1px solid var(--el-border-color-light);
  background: var(--el-bg-color-overlay);
  overflow: hidden;
  transition: all 0.3s ease;

  &:hover {
    transform: translateY(-3px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
  }
}

.card-accent {
  position: absolute;
  top: 0;
  left: 0;
  width: 4px;
  height: 100%;
  border-radius: 0 2px 2px 0;
}

.card-icon {
  width: 44px;
  height: 44px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  background: rgba(99, 102, 241, 0.08);
}

.card-body {
  display: flex;
  flex-direction: column;
  min-width: 0;
  flex: 1;
}

.card-label {
  font-size: 12px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  color: var(--el-text-color-secondary);
  margin-bottom: 4px;
}

.card-value {
  font-size: 20px;
  font-weight: 700;
  color: var(--el-text-color-primary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;

  &--pct {
    font-size: 18px;
  }
}

.card-progress-row {
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.color-green {
  color: #34d399;
}

.color-red {
  color: #ef4444;
}

.monitor-progress {
  width: 100%;
}

/* Per-card accent colors */
.version-card {
  .card-accent { background: #818cf8; }
  .card-icon { background: rgba(129, 140, 248, 0.1); color: #818cf8; }
}

.cpu-card {
  .card-accent { background: #818cf8; }
  .card-icon { background: rgba(129, 140, 248, 0.1); color: #818cf8; }
}

.mem-card {
  .card-accent { background: #34d399; }
  .card-icon { background: rgba(52, 211, 153, 0.1); color: #34d399; }
}

.disk-card {
  .card-accent { background: #fbbf24; }
  .card-icon { background: rgba(251, 191, 36, 0.1); color: #fbbf24; }
}

.hv-card {
  .card-accent { background: #a78bfa; }
  .card-icon { background: rgba(167, 139, 250, 0.1); color: #a78bfa; }
}

.running-card {
  .card-accent { background: #34d399; }
  .card-icon { background: rgba(52, 211, 153, 0.1); color: #34d399; }
}

.users-card {
  .card-accent { background: #f472b6; }
  .card-icon { background: rgba(244, 114, 182, 0.1); color: #f472b6; }
}

.device-card {
  .card-accent { background: #38bdf8; }
  .card-icon { background: rgba(56, 189, 248, 0.1); color: #38bdf8; }
}

@media (max-width: 768px) {
  .dashboard-container {
    padding: 16px;
  }

  .monitor-grid {
    grid-template-columns: 1fr;
  }
}
</style>
