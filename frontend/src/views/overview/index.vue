<template>
  <div class="overview">
    <div class="overview-header">
      <div class="greeting-card">
        <div class="greeting-avatar">
          <img src="/src/assets/logo.png" alt="logo" />
        </div>
        <div class="greeting-text">
          <h2>{{ greetings }}</h2>
          <p>{{ $t("account.createTime") }}: {{ timestampToDateTime(account.createTime) }}</p>
        </div>
        <div class="greeting-actions">
          <el-button size="default" type="primary" @click="handleSubscribe">
            {{ $t("common.subscribe") }}
          </el-button>
          <el-button size="default" @click="handleSubscribeQrCode">
            {{ $t("common.subscribeQrCode") }}
          </el-button>
          <el-button size="default" @click="handleNodeUrl">
            {{ $t("common.nodeUrl") }}
          </el-button>
          <el-button size="default" @click="handleUrlQrCode">
            {{ $t("common.nodeQrCode") }}
          </el-button>
        </div>
      </div>
    </div>

    <div class="stats-row">
      <div class="stat-card">
        <div class="stat-icon" style="background: rgba(99,102,241,0.1); color: #818cf8;">
          <svg-icon icon-class="quota" size="1.4em" />
        </div>
        <div class="stat-body">
          <span class="stat-label">{{ $t("account.quota") }}</span>
          <span class="stat-value">{{ formatBytes(account.quota) }}</span>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon" style="background: rgba(52,211,153,0.1); color: #34d399;">
          <svg-icon icon-class="download" size="1.4em" />
        </div>
        <div class="stat-body">
          <span class="stat-label">{{ $t("account.download") }}</span>
          <span class="stat-value">{{ formatBytes(account.download) }}</span>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon" style="background: rgba(251,191,36,0.1); color: #fbbf24;">
          <svg-icon icon-class="upload" size="1.4em" />
        </div>
        <div class="stat-body">
          <span class="stat-label">{{ $t("account.upload") }}</span>
          <span class="stat-value">{{ formatBytes(account.upload) }}</span>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon" style="background: rgba(244,114,182,0.1); color: #f472b6;">
          <svg-icon icon-class="expire-time" size="1.4em" />
        </div>
        <div class="stat-body">
          <span class="stat-label">{{ $t("account.expireTime") }}</span>
          <span class="stat-value stat-value--sm">{{ timestampToDateTime(account.expireTime) }}</span>
        </div>
      </div>
    </div>

    <div v-if="isAdmin" class="monitor-section">
      <h3 class="section-title">System Monitor</h3>
      <div class="monitor-grid">
        <div class="monitor-card">
          <div class="monitor-card-accent" style="background:#818cf8"></div>
          <div class="monitor-card-icon" style="background:rgba(129,140,248,0.1); color:#818cf8;">
            <svg-icon icon-class="honestui" size="1.3em" />
          </div>
          <div class="monitor-card-body">
            <span class="monitor-card-label">{{ $t("monitor.huiVersion") }}</span>
            <span class="monitor-card-value">{{ systemMonitor.huiVersion || "-" }}</span>
          </div>
        </div>

        <div class="monitor-card">
          <div class="monitor-card-accent" style="background:#34d399"></div>
          <div class="monitor-card-icon" style="background:rgba(52,211,153,0.1); color:#34d399;">
            <svg-icon icon-class="setting" size="1.3em" />
          </div>
          <div class="monitor-card-body">
            <span class="monitor-card-label">{{ $t("monitor.cpuPercent") }}</span>
            <div class="progress-row">
              <span class="monitor-card-value">{{ systemMonitor.cpuPercent != null ? systemMonitor.cpuPercent + "%" : "-" }}</span>
              <el-progress v-if="systemMonitor.cpuPercent != null" :percentage="Math.round(systemMonitor.cpuPercent)" :stroke-width="5" :show-text="false" color="#818cf8" class="mini-progress" />
            </div>
          </div>
        </div>

        <div class="monitor-card">
          <div class="monitor-card-accent" style="background:#fbbf24"></div>
          <div class="monitor-card-icon" style="background:rgba(251,191,36,0.1); color:#fbbf24;">
            <svg-icon icon-class="size" size="1.3em" />
          </div>
          <div class="monitor-card-body">
            <span class="monitor-card-label">{{ $t("monitor.memPercent") }}</span>
            <div class="progress-row">
              <span class="monitor-card-value">{{ systemMonitor.memPercent != null ? systemMonitor.memPercent + "%" : "-" }}</span>
              <el-progress v-if="systemMonitor.memPercent != null" :percentage="Math.round(systemMonitor.memPercent)" :stroke-width="5" :show-text="false" color="#34d399" class="mini-progress" />
            </div>
          </div>
        </div>

        <div class="monitor-card">
          <div class="monitor-card-accent" style="background:#38bdf8"></div>
          <div class="monitor-card-icon" style="background:rgba(56,189,248,0.1); color:#38bdf8;">
            <svg-icon icon-class="download" size="1.3em" />
          </div>
          <div class="monitor-card-body">
            <span class="monitor-card-label">{{ $t("monitor.diskPercent") }}</span>
            <div class="progress-row">
              <span class="monitor-card-value">{{ systemMonitor.diskPercent != null ? systemMonitor.diskPercent + "%" : "-" }}</span>
              <el-progress v-if="systemMonitor.diskPercent != null" :percentage="Math.round(systemMonitor.diskPercent)" :stroke-width="5" :show-text="false" color="#38bdf8" class="mini-progress" />
            </div>
          </div>
        </div>

        <div class="monitor-card">
          <div class="monitor-card-accent" style="background:#a78bfa"></div>
          <div class="monitor-card-icon" style="background:rgba(167,139,250,0.1); color:#a78bfa;">
            <svg-icon icon-class="hysteria" size="1.3em" />
          </div>
          <div class="monitor-card-body">
            <span class="monitor-card-label">{{ $t("monitor.hysteria2Version") }}</span>
            <span class="monitor-card-value">{{ hysteria2Monitor.version || "-" }}</span>
          </div>
        </div>

        <div class="monitor-card">
          <div class="monitor-card-accent" :style="{ background: runningColor }"></div>
          <div class="monitor-card-icon" :style="{ background: runningBg, color: runningColor }">
            <svg-icon icon-class="report" size="1.3em" />
          </div>
          <div class="monitor-card-body">
            <span class="monitor-card-label">{{ $t("monitor.hysteria2Running") }}</span>
            <span class="monitor-card-value" :class="hysteria2Monitor.running === true ? 'text-green' : hysteria2Monitor.running === false ? 'text-red' : ''">
              {{ hysteria2Monitor.running === undefined ? "-" : hysteria2Monitor.running ? $t("monitor.hysteria2RunningTrue") : $t("monitor.hysteria2RunningFalse") }}
            </span>
          </div>
        </div>

        <div class="monitor-card">
          <div class="monitor-card-accent" style="background:#f472b6"></div>
          <div class="monitor-card-icon" style="background:rgba(244,114,182,0.1); color:#f472b6;">
            <svg-icon icon-class="users" size="1.3em" />
          </div>
          <div class="monitor-card-body">
            <span class="monitor-card-label">{{ $t("monitor.hysteria2UserTotal") }}</span>
            <span class="monitor-card-value">{{ hysteria2Monitor.userTotal }}</span>
          </div>
        </div>

        <div class="monitor-card">
          <div class="monitor-card-accent" style="background:#f59e0b"></div>
          <div class="monitor-card-icon" style="background:rgba(245,158,11,0.1); color:#f59e0b;">
            <svg-icon icon-class="share" size="1.3em" />
          </div>
          <div class="monitor-card-body">
            <span class="monitor-card-label">{{ $t("monitor.hysteria2DeviceTotal") }}</span>
            <span class="monitor-card-value">{{ hysteria2Monitor.deviceTotal }}</span>
          </div>
        </div>
      </div>
    </div>

    <el-dialog :title="qrCodeDialog.title" v-model="qrCodeDialog.visible" width="600px" append-to-body @close="qrCodeDialog.visible = false">
      <el-form style="text-align: center">
        <el-image style="width: 300px; height: 300px" :src="qrCodeSrc" />
      </el-form>
      <template #footer>
        <el-button type="primary" @click="qrCodeDialog.visible = false">{{ $t("common.confirm") }}</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script lang="ts">
export default { name: "OverviewIndex" }
</script>

<script setup lang="ts">
import { getAccountApi, verifyDefaultPassApi } from "@/api/account";
import { monitorHysteria2Api, monitorSystemApi } from "@/api/monitor";
import { AccountVo } from "@/api/account/types";
import { useAccountStore } from "@/store/modules/account";
import { timestampToDateTime } from "@/utils/time";
import { formatBytes, formatStorageUnit } from "@/utils/byte";
import { hysteria2SubscribeUrlApi, hysteria2UrlApi } from "@/api/hysteria2";
import { Hysteria2SubscribeUrlDto, Hysteria2UrlDto } from "@/api/hysteria2/types";
import copy from "copy-to-clipboard";
import { useI18n } from "vue-i18n";

const { t } = useI18n();
const accountStore = useAccountStore();
const isAdmin = computed(() => accountStore.roles.indexOf("admin") !== -1);

const date = new Date();
const greetings = computed(() => {
  const hours = date.getHours();
  if (hours >= 6 && hours < 8) return t("info.greeting1");
  if (hours >= 8 && hours < 12) return t("info.greeting2") + accountStore.username + "!";
  if (hours >= 12 && hours < 18) return t("info.greeting3") + accountStore.username + "!";
  if (hours >= 18 && hours < 24) return t("info.greeting4") + accountStore.username + "!";
  if (hours >= 0 && hours < 6) return t("info.greeting5");
  return "Hello Honest-UI";
});

const state = reactive({
  account: {} as AccountVo,
  systemMonitor: { huiVersion: "", cpuPercent: 0, memPercent: 0, diskPercent: 0 },
  hysteria2Monitor: { userTotal: 0, deviceTotal: 0, version: undefined as string | undefined, running: undefined as boolean | undefined },
  qrCodeDialog: { title: "QR Code", visible: false } as { title: string; visible: boolean },
  qrCodeSrc: "",
});

const { account, systemMonitor, hysteria2Monitor, qrCodeDialog, qrCodeSrc } = toRefs(state);

const runningColor = computed(() => {
  if (hysteria2Monitor.value.running === true) return "#34d399";
  if (hysteria2Monitor.value.running === false) return "#ef4444";
  return "#6b7280";
});
const runningBg = computed(() => {
  if (hysteria2Monitor.value.running === true) return "rgba(52,211,153,0.1)";
  if (hysteria2Monitor.value.running === false) return "rgba(239,68,68,0.1)";
  return "rgba(107,114,128,0.1)";
});

let pollTimer: ReturnType<typeof setInterval> | null = null;

const fetchAccount = () => {
  getAccountApi({ id: accountStore.id }).then((res) => { Object.assign(state.account, res.data); });
};

const fetchMonitor = () => {
  monitorSystemApi().then((res) => { Object.assign(state.systemMonitor, res.data); });
  monitorHysteria2Api().then((res) => { Object.assign(state.hysteria2Monitor, res.data); });
};

const handleSubscribe = async () => {
  try {
    const dto: Hysteria2SubscribeUrlDto = { accountId: accountStore.id, protocol: window.location.protocol, host: window.location.host };
    const { data } = await hysteria2SubscribeUrlApi(dto);
    copy(data.url); ElMessage.success(t("common.copySuccess"));
  } catch { /* empty */ }
};
const handleSubscribeQrCode = async () => {
  try {
    const dto: Hysteria2SubscribeUrlDto = { accountId: accountStore.id, protocol: window.location.protocol, host: window.location.host };
    const { data } = await hysteria2SubscribeUrlApi(dto);
    state.qrCodeSrc = "data:image/png;base64," + data.qrCode; state.qrCodeDialog.visible = true;
  } catch { /* empty */ }
};
const handleNodeUrl = async () => {
  try {
    const dto: Hysteria2UrlDto = { accountId: accountStore.id, hostname: window.location.hostname };
    const { data } = await hysteria2UrlApi(dto);
    copy(data.url); ElMessage.success(t("common.copySuccess"));
  } catch { /* empty */ }
};
const handleUrlQrCode = async () => {
  try {
    const dto: Hysteria2UrlDto = { accountId: accountStore.id, hostname: window.location.hostname };
    const { data } = await hysteria2UrlApi(dto);
    state.qrCodeSrc = "data:image/png;base64," + data.qrCode; state.qrCodeDialog.visible = true;
  } catch { /* empty */ }
};

onMounted(() => {
  fetchAccount();
  if (isAdmin.value) {
    fetchMonitor();
    pollTimer = setInterval(fetchMonitor, 5000);
    verifyDefaultPassApi().then((res) => {
      if (res.data) {
        ElNotification({ title: t("common.securityRisk"), dangerouslyUseHTMLString: true, message: t("common.defaultPassTip"), type: "warning" });
      }
    });
    if (window.location.protocol !== "https:") {
      ElNotification({ title: t("common.securityRisk"), dangerouslyUseHTMLString: true, message: t("common.noHttpsTip"), type: "warning" });
    }
  }
});

onBeforeUnmount(() => {
  if (pollTimer) clearInterval(pollTimer);
});
</script>

<style lang="scss" scoped>
.overview {
  padding: 24px;
  max-width: 1400px;
  margin: 0 auto;
}

.overview-header {
  margin-bottom: 24px;
}

.greeting-card {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 16px;
  padding: 20px 24px;
  background: linear-gradient(135deg, rgba(99,102,241,0.06) 0%, rgba(99,102,241,0.01) 100%);
  border: 1px solid rgba(99,102,241,0.1);
  border-radius: 16px;
}

.greeting-avatar {
  width: 52px;
  height: 52px;
  border-radius: 14px;
  background: linear-gradient(135deg, #6366f1, #4f46e5);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  img {
    width: 44px;
    height: 44px;
    border-radius: 10px;
  }
}

.greeting-text {
  flex: 1;
  min-width: 200px;
  h2 {
    margin: 0 0 4px;
    font-size: 18px;
    font-weight: 700;
    color: var(--el-text-color-primary);
  }
  p {
    margin: 0;
    font-size: 13px;
    color: var(--el-text-color-secondary);
  }
}

.greeting-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.stats-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 16px;
  margin-bottom: 24px;
}

.stat-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 18px 20px;
  border-radius: 14px;
  border: 1px solid var(--el-border-color-light);
  background: var(--el-bg-color-overlay);
  transition: all 0.25s ease;
  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(0,0,0,0.08);
  }
}

.stat-icon {
  width: 44px;
  height: 44px;
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
  &--sm { font-size: 13px; }
}

.section-title {
  margin: 0 0 16px;
  font-size: 16px;
  font-weight: 700;
  color: var(--el-text-color-primary);
}

.monitor-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
  gap: 14px;
}

.monitor-card {
  position: relative;
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 18px 20px;
  border-radius: 14px;
  border: 1px solid var(--el-border-color-light);
  background: var(--el-bg-color-overlay);
  overflow: hidden;
  transition: all 0.25s ease;
  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(0,0,0,0.08);
  }
}

.monitor-card-accent {
  position: absolute;
  top: 0; left: 0;
  width: 4px;
  height: 100%;
  border-radius: 0 2px 2px 0;
}

.monitor-card-icon {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.monitor-card-body {
  display: flex;
  flex-direction: column;
  min-width: 0;
  flex: 1;
}

.monitor-card-label {
  font-size: 11px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  color: var(--el-text-color-secondary);
  margin-bottom: 4px;
}

.monitor-card-value {
  font-size: 18px;
  font-weight: 700;
  color: var(--el-text-color-primary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.text-green { color: #34d399; }
.text-red { color: #ef4444; }

.progress-row {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.mini-progress {
  width: 100%;
}

@media (max-width: 768px) {
  .overview { padding: 16px; }
  .stats-row { grid-template-columns: 1fr; }
  .monitor-grid { grid-template-columns: 1fr; }
}
</style>
