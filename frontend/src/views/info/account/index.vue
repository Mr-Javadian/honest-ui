<template>
  <div class="dashboard-container">
    <div class="profile-card">
      <div class="profile-info">
        <div class="avatar-wrapper">
          <img class="avatar" src="/src/assets/logo.png" />
        </div>
        <div class="profile-text">
          <h2 class="greeting">{{ greetings }}</h2>
          <p class="member-since">
            {{ $t("account.createTime") }}: {{ timestampToDateTime(account.createTime) }}
          </p>
        </div>
      </div>

      <div class="profile-actions">
        <el-button type="primary" :icon="Share" @click="handleSubscribe">
          {{ $t("common.subscribe") }}
        </el-button>
        <el-button type="primary" :icon="Share" @click="handleSubscribeQrCode">
          {{ $t("common.subscribeQrCode") }}
        </el-button>
        <el-button :icon="Share" @click="handleNodeUrl">
          {{ $t("common.nodeUrl") }}
        </el-button>
        <el-button :icon="Share" @click="handleUrlQrCode">
          {{ $t("common.nodeQrCode") }}
        </el-button>
      </div>
    </div>

    <div class="stats-grid">
      <div class="stat-card quota-card">
        <div class="stat-icon">
          <svg-icon icon-class="quota" size="1.6em" />
        </div>
        <div class="stat-body">
          <span class="stat-label">{{ $t("account.quota") }}</span>
          <span class="stat-value">{{ formatBytes(account.quota) }}</span>
          <span class="stat-unit">{{ formatStorageUnit(account.quota) }}</span>
        </div>
      </div>

      <div class="stat-card download-card">
        <div class="stat-icon">
          <svg-icon icon-class="download" size="1.6em" />
        </div>
        <div class="stat-body">
          <span class="stat-label">{{ $t("account.download") }}</span>
          <span class="stat-value">{{ formatBytes(account.download) }}</span>
          <span class="stat-unit">{{ formatStorageUnit(account.download) }}</span>
        </div>
      </div>

      <div class="stat-card upload-card">
        <div class="stat-icon">
          <svg-icon icon-class="upload" size="1.6em" />
        </div>
        <div class="stat-body">
          <span class="stat-label">{{ $t("account.upload") }}</span>
          <span class="stat-value">{{ formatBytes(account.upload) }}</span>
          <span class="stat-unit">{{ formatStorageUnit(account.upload) }}</span>
        </div>
      </div>

      <div class="stat-card expire-card">
        <div class="stat-icon">
          <svg-icon icon-class="expire-time" size="1.6em" />
        </div>
        <div class="stat-body">
          <span class="stat-label">{{ $t("account.expireTime") }}</span>
          <span class="stat-value stat-value--sm">{{ timestampToDateTime(account.expireTime) }}</span>
          <span class="stat-unit">{{ $t("info.expireTime") }}</span>
        </div>
      </div>
    </div>

    <el-dialog
      :title="qrCodeDialog.title"
      v-model="qrCodeDialog.visible"
      width="600px"
      append-to-body
      @close="qrCodeDialog.visible = false"
    >
      <el-form style="text-align: center">
        <el-image
          style="width: 300px; height: 300px"
          :src="qrCodeSrc"
        ></el-image>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button type="primary" @click="qrCodeDialog.visible = false">
            {{ $t("common.confirm") }}
          </el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script lang="ts">
export default {
  name: "AccountInfo",
};
</script>

<script setup lang="ts">
import { getAccountApi, verifyDefaultPassApi } from "@/api/account";
import { AccountVo } from "@/api/account/types";
import { useAccountStore } from "@/store/modules/account";
import { timestampToDateTime } from "@/utils/time";
import { formatBytes, formatStorageUnit } from "@/utils/byte";
import { Share } from "@element-plus/icons-vue";
import { useI18n } from "vue-i18n";
import {
  Hysteria2SubscribeUrlDto,
  Hysteria2UrlDto,
} from "@/api/hysteria2/types";
import { hysteria2SubscribeUrlApi, hysteria2UrlApi } from "@/api/hysteria2";
import copy from "copy-to-clipboard";

const { t } = useI18n();
const accountStore = useAccountStore();

const date: Date = new Date();

const greetings = computed(() => {
  const hours = date.getHours();
  if (hours >= 6 && hours < 8) {
    return t("info.greeting1");
  } else if (hours >= 8 && hours < 12) {
    return t("info.greeting2") + accountStore.username + "!";
  } else if (hours >= 12 && hours < 18) {
    return t("info.greeting3") + accountStore.username + "!";
  } else if (hours >= 18 && hours < 24) {
    return t("info.greeting4") + accountStore.username + "!";
  } else if (hours >= 0 && hours < 6) {
    return t("info.greeting5");
  }
  return "Hello Honest-UI";
});

const state = reactive({
  account: {} as AccountVo,
  qrCodeDialog: {
    title: "QR Code",
    visible: false,
  } as DialogType,
  qrCodeSrc: "",
});

const { qrCodeDialog, account, qrCodeSrc } = toRefs(state);

const handleSubscribe = async () => {
  try {
    const dto: Hysteria2SubscribeUrlDto = {
      accountId: accountStore.id,
      protocol: window.location.protocol,
      host: window.location.host,
    };
    const { data } = await hysteria2SubscribeUrlApi(dto);
    copy(data.url);
    ElMessage.success(t("common.copySuccess"));
  } catch (e) {
    /* empty */
  }
};

const handleSubscribeQrCode = async () => {
  try {
    const dto: Hysteria2SubscribeUrlDto = {
      accountId: accountStore.id,
      protocol: window.location.protocol,
      host: window.location.host,
    };
    const { data } = await hysteria2SubscribeUrlApi(dto);
    state.qrCodeSrc = "data:image/png;base64," + data.qrCode;
    state.qrCodeDialog.visible = true;
  } catch (e) {
    /* empty */
  }
};

const handleNodeUrl = async () => {
  try {
    const dto: Hysteria2UrlDto = {
      accountId: accountStore.id,
      hostname: window.location.hostname,
    };
    const { data } = await hysteria2UrlApi(dto);
    copy(data.url);
    ElMessage.success(t("common.copySuccess"));
  } catch (e) {
    /* empty */
  }
};

const handleUrlQrCode = async () => {
  try {
    const dto: Hysteria2UrlDto = {
      accountId: accountStore.id,
      hostname: window.location.hostname,
    };
    const { data } = await hysteria2UrlApi(dto);
    state.qrCodeSrc = "data:image/png;base64," + data.qrCode;
    state.qrCodeDialog.visible = true;
  } catch (e) {
    /* empty */
  }
};

onMounted(() => {
  getAccountApi({ id: accountStore.id }).then((response) => {
    Object.assign(state.account, response.data);
  });
  if (accountStore.roles.indexOf("admin") != -1) {
    verifyDefaultPassApi().then((response) => {
      if (response.data) {
        ElNotification({
          title: t("common.securityRisk"),
          dangerouslyUseHTMLString: true,
          message: t("common.defaultPassTip"),
          type: "warning",
        });
      }
    });
    if (window.location.protocol !== "https:") {
      ElNotification({
        title: t("common.securityRisk"),
        dangerouslyUseHTMLString: true,
        message: t("common.noHttpsTip"),
        type: "warning",
      });
    }
  }
});
</script>

<style lang="scss" scoped>
.dashboard-container {
  padding: 24px;
  max-width: 1200px;
  margin: 0 auto;
}

/* ── Profile Card ── */
.profile-card {
  background: linear-gradient(135deg, rgba(99, 102, 241, 0.08) 0%, rgba(99, 102, 241, 0.02) 100%);
  border: 1px solid rgba(99, 102, 241, 0.12);
  border-radius: 16px;
  padding: 24px 28px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 16px;
  margin-bottom: 24px;
}

.profile-info {
  display: flex;
  align-items: center;
  gap: 16px;
}

.avatar-wrapper {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  background: linear-gradient(135deg, #6366f1, #4f46e5);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.avatar {
  width: 56px;
  height: 56px;
  border-radius: 50%;
  border: 2px solid #fff;
}

.profile-text {
  .greeting {
    margin: 0 0 4px;
    font-size: 20px;
    font-weight: 700;
    color: var(--el-text-color-primary);
  }

  .member-since {
    margin: 0;
    font-size: 13px;
    color: var(--el-text-color-secondary);
  }
}

.profile-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

/* ── Stats Grid ── */
.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 16px;
}

.stat-card {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px 24px;
  border-radius: 14px;
  border: 1px solid var(--el-border-color-light);
  background: var(--el-bg-color-overlay);
  transition: all 0.3s ease;

  &:hover {
    transform: translateY(-3px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
  }
}

.stat-icon {
  width: 48px;
  height: 48px;
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
  font-size: 12px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  color: var(--el-text-color-secondary);
  margin-bottom: 2px;
}

.stat-value {
  font-size: 20px;
  font-weight: 700;
  color: var(--el-text-color-primary);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;

  &--sm {
    font-size: 14px;
  }
}

.stat-unit {
  font-size: 11px;
  color: var(--el-text-color-placeholder);
  margin-top: 1px;
}

/* Per-card accent colors */
.quota-card {
  .stat-icon {
    background: rgba(99, 102, 241, 0.1);
    color: #818cf8;
  }
}

.download-card {
  .stat-icon {
    background: rgba(52, 211, 153, 0.1);
    color: #34d399;
  }
}

.upload-card {
  .stat-icon {
    background: rgba(251, 191, 36, 0.1);
    color: #fbbf24;
  }
}

.expire-card {
  .stat-icon {
    background: rgba(244, 114, 182, 0.1);
    color: #f472b6;
  }
}

@media (max-width: 768px) {
  .dashboard-container {
    padding: 16px;
  }

  .profile-card {
    flex-direction: column;
    align-items: flex-start;
    padding: 20px;
  }

  .profile-actions {
    width: 100%;
    flex-wrap: wrap;

    .el-button {
      flex: 1;
      min-width: calc(50% - 4px);
    }
  }

  .stats-grid {
    grid-template-columns: 1fr;
  }
}
</style>
