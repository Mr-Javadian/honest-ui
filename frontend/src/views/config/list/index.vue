<template>
  <div class="page-container">
    <div class="page-header">
      <div class="header-left">
        <h2 class="page-title">{{ $t("route.configList") }}</h2>
        <p class="page-subtitle">{{ $t("config.subtitle") || "Configure panel settings, proxy, and interface preferences" }}</p>
      </div>
      <div class="header-actions">
        <el-button type="primary" @click="submitForm" :icon="Select" size="default">
          {{ $t("common.save") }}
        </el-button>
        <el-button @click="handleRestartServer" size="default">
          <template #icon><i-ep-refreshRight /></template>
          {{ $t("config.restartServer") }}
        </el-button>
        <el-upload
          v-model:file-list="fileList"
          :http-request="handleImport"
          :show-file-list="false"
          accept=".json"
          :limit="1"
          :before-upload="beforeImport"
        >
          <el-button size="default">
            <template #icon><i-ep-upload /></template>
            {{ $t("common.import") }}
          </el-button>
        </el-upload>
        <el-button @click="handleExport" size="default">
          <template #icon><i-ep-download /></template>
          {{ $t("common.export") }}
        </el-button>
      </div>
    </div>

    <el-form
      ref="dataFormRef"
      :rules="dataFormRules"
      :model="dataForm"
      label-position="top"
    >
      <div class="settings-grid">
        <div class="settings-card">
          <div class="card-header">
            <div class="card-icon"><i-ep-monitor /></div>
            <div>
              <h3 class="card-title">{{ $t("config.webSettings") || "Web Server Configuration" }}</h3>
              <p class="card-desc">{{ $t("config.webSettingsDesc") || "Configure the port and context path for the Honest-UI web panel." }}</p>
            </div>
          </div>
          <div class="card-body">
            <div class="form-row three-col">
              <el-form-item :label="$t('config.huiWebPort') || 'Web Panel Port'" prop="huiWebPort">
                <el-input
                  v-model="dataForm.huiWebPort"
                  placeholder="e.g., 8081"
                  clearable
                />
              </el-form-item>
              <el-form-item :label="$t('config.huiWebContext') || 'Web Root Context Path'" prop="huiWebContext">
                <el-input
                  v-model="dataForm.huiWebContext"
                  placeholder="e.g., /hui or /admin"
                  clearable
                />
              </el-form-item>
              <el-form-item :label="$t('config.timezone') || 'System Timezone'" prop="timeZone">
                <el-select v-model="dataForm.timeZone" filterable clearable :placeholder="$t('config.selectTimezone') || 'Select timezone'">
                  <el-option v-for="tz in timezoneList" :key="tz" :label="tz" :value="tz" />
                </el-select>
              </el-form-item>
            </div>
          </div>
        </div>

        <div class="settings-card">
          <div class="card-header">
            <div class="card-icon"><i-ep-connection /></div>
            <div>
              <h3 class="card-title">{{ $t("config.hysteria2Settings") || "Hysteria2 Protocol Settings" }}</h3>
              <p class="card-desc">{{ $t("config.hysteria2SettingsDesc") || "Configure traffic synchronization intervals and auto-reset rules for Hysteria2." }}</p>
            </div>
          </div>
          <div class="card-body">
            <div class="form-row two-col">
              <el-form-item
                :label="$t('config.hysteria2TrafficTime') || 'Traffic Sync Interval (seconds)'"
                prop="hysteria2TrafficTime"
              >
                <el-input
                  v-model="dataForm.hysteria2TrafficTime"
                  placeholder="e.g., 1"
                  clearable
                />
              </el-form-item>
              <el-form-item
                :label="$t('config.resetTrafficCron') || 'Traffic Auto-Reset Schedule'"
                prop="resetTrafficCron"
              >
                <el-tooltip
                  :content="$t('config.resetTrafficCronTip') || 'Select schedule: Daily, Weekly, Monthly, or Never'"
                  placement="bottom"
                  :teleported="false"
                >
                  <el-select
                    v-model="dataForm.resetTrafficCron"
                    clearable
                    :placeholder="$t('config.resetTrafficCron') || 'Select schedule: Daily, Weekly, Monthly, or Never'"
                  >
                    <el-option
                      v-for="item in cronResetTraffic"
                      :key="item.value"
                      :label="item.key"
                      :value="item.value"
                    />
                  </el-select>
                </el-tooltip>
              </el-form-item>
            </div>
          </div>
        </div>

        <div class="settings-card">
          <div class="card-header">
            <div class="card-icon"><i-ep-link /></div>
            <div>
              <h3 class="card-title">{{ $t("config.httpsSettings") || "HTTPS & SSL/TLS Configuration" }}</h3>
              <p class="card-desc">{{ $t("config.httpsSettingsDesc") || "Enable HTTPS and manage SSL certificates for the web panel." }}</p>
            </div>
          </div>
          <div class="card-body">
            <div class="form-row single-col">
              <el-form-item :label="$t('config.huiHttps') || 'Enable HTTPS for Web Panel'" prop="huiHttps">
                <div class="https-toggle">
                  <el-select v-model="huiHttps" ref="huiHttpsRef" style="width:200px">
                    <el-option
                      v-for="item in huiHttpsList"
                      :key="item.key"
                      :label="item.key"
                      :value="item.value"
                    />
                  </el-select>
                  <el-button v-if="huiHttps" @click="setCertPath" size="default">
                    {{ t("config.useHysteria2Cert") }}
                  </el-button>
                </div>
              </el-form-item>
            </div>
            <div v-if="huiHttps" class="form-row two-col">
              <el-form-item
                :label="$t('config.huiCrtPath')"
                prop="huiCrtPath"
              >
                <div class="input-with-action">
                  <el-input
                    v-model="dataForm.huiCrtPath"
                    :placeholder="$t('config.huiCrtPath')"
                    clearable
                  />
                  <el-upload
                    ref="uploadCrtFile"
                    action=""
                    :file-list="crtFileList"
                    :http-request="uploadCertFile"
                    accept=".crt"
                    :before-upload="() => { crtFileList = []; }"
                    :show-file-list="false"
                    :limit="1"
                  >
                    <template #trigger>
                      <el-button size="small">{{ t("config.uploadCrtFile") }}</el-button>
                    </template>
                  </el-upload>
                </div>
              </el-form-item>
              <el-form-item
                :label="$t('config.huiKeyPath')"
                prop="huiKeyPath"
              >
                <div class="input-with-action">
                  <el-input
                    v-model="dataForm.huiKeyPath"
                    :placeholder="$t('config.huiKeyPath')"
                    clearable
                  />
                  <el-upload
                    ref="uploadKeyFile"
                    action=""
                    :file-list="keyFileList"
                    :http-request="uploadCertFile"
                    accept=".key"
                    :before-upload="() => { keyFileList = []; }"
                    :show-file-list="false"
                    :limit="1"
                  >
                    <template #trigger>
                      <el-button size="small">{{ t("config.uploadKeyFile") }}</el-button>
                    </template>
                  </el-upload>
                </div>
              </el-form-item>
            </div>
          </div>
        </div>

        <div class="settings-card">
          <div class="card-header">
            <div class="card-icon"><i-ep-setting /></div>
            <div>
              <h3 class="card-title">{{ $t("config.interfaceSettings") || "User Interface & Appearance" }}</h3>
              <p class="card-desc">{{ $t("config.interfaceSettingsDesc") || "Customize language, theme, layout, and brand elements of the dashboard." }}</p>
            </div>
          </div>
          <div class="card-body">
            <div class="preference-list">
              <div class="preference-item">
                <div class="pref-info">
                  <span class="pref-label">Language</span>
                  <span class="pref-hint">{{ $t("config.langHint") || "Select your preferred UI language" }}</span>
                </div>
                <lang-select class="pref-control" />
              </div>
              <div class="preference-item">
                <div class="pref-info">
                  <span class="pref-label">UI Density</span>
                  <span class="pref-hint">{{ $t("config.sizeHint") || "Adjust the compactness of the layout (Comfortable, Compact)" }}</span>
                </div>
                <size-select class="pref-control" />
              </div>
              <div class="preference-item">
                <div class="pref-info">
                  <span class="pref-label">Color Theme</span>
                  <span class="pref-hint">{{ $t("config.themeHint") || "Switch between Light, Dark, and Ultra modes" }}</span>
                </div>
                <div class="theme-group">
                  <button class="theme-btn" :class="{ active: theme === 'light' }" @click="theme !== 'light' && cycleTheme()">
                    <i-ep-sunny />
                    <span class="theme-btn-label">Light Mode</span>
                  </button>
                  <button class="theme-btn" :class="{ active: theme === 'dark' }" @click="theme !== 'dark' && cycleTheme()">
                    <i-ep-moon />
                    <span class="theme-btn-label">Dark Mode</span>
                  </button>
                  <button class="theme-btn" :class="{ active: theme === 'ultra-dark' }" @click="theme !== 'ultra-dark' && cycleTheme()">
                    <i-ep-star-filled />
                    <span class="theme-btn-label">Ultra (High Contrast)</span>
                  </button>
                </div>
              </div>
              <div class="preference-item">
                <div class="pref-info">
                  <span class="pref-label">Show Sidebar Logo</span>
                  <span class="pref-hint">{{ $t("config.logoHint") || "Display the product logo in the sidebar header" }}</span>
                </div>
                <el-switch v-model="settingsStore.sidebarLogo" />
              </div>
              <div class="preference-item">
                <div class="pref-info">
                  <span class="pref-label">Primary Theme Color</span>
                  <span class="pref-hint">{{ $t("config.colorHint") || "Choose the main accent color for the interface" }}</span>
                </div>
                <div class="color-group">
                  <span
                    v-for="color in themeColors"
                    :key="color"
                    class="color-swatch"
                    :style="{ background: color }"
                    :class="{ active: settingsStore.themeColor === color }"
                    @click="changeThemeColor(color)"
                  />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </el-form>
  </div>
</template>

<script lang="ts">
export default {
  name: "index",
  components: { LangSelect, SizeSelect },
};
</script>

<script setup lang="ts">
import LangSelect from "@/components/LangSelect/index.vue";
import SizeSelect from "@/components/SizeSelect/index.vue";
import { useSettingsStore } from "@/store/modules/settings";
import { useAppTheme } from "@/hooks/useTheme";
import { Select } from "@element-plus/icons-vue";
import {
  exportConfigApi,
  hysteria2AcmePathApi,
  importConfigApi,
  listConfigApi,
  restartServerApi,
  updateConfigsApi,
  uploadCertFileApi,
} from "@/api/config";
import { ConfigsUpdateDto } from "@/api/config/types";
import {
  UploadFile,
  UploadRawFile,
  UploadRequestOptions,
} from "element-plus/lib/components";
import { useI18n } from "vue-i18n";
import { useRoute } from "vue-router";
import { UploadUserFile } from "element-plus";

const settingsStore = useSettingsStore();
const { theme, cycleTheme } = useAppTheme();

const themeColors = ["#409EFF", "#304156", "#11a983", "#13c2c2", "#6959CD", "#f5222d"];

function changeThemeColor(color: string) {
  settingsStore.changeSetting({ key: "themeColor", value: color });
  document.documentElement.style.setProperty("--el-color-primary", settingsStore.themeColor);
}

const { t } = useI18n();
const route = useRoute();

const dataFormRef = ref(ElForm);
const huiHttpsRef = ref(ElSelect);

const huiWebPortKey = "H_UI_WEB_PORT";
const huiWebContext = "H_UI_WEB_CONTEXT";
const hysteria2TrafficTimeKey = "HYSTERIA2_TRAFFIC_TIME";
const huiCrtPathKey = "H_UI_CRT_PATH";
const huiKeyPathKey = "H_UI_KEY_PATH";
const resetTrafficCronKey = "RESET_TRAFFIC_CRON";
const timeZoneKey = "TIME_ZONE";

const timezoneList = [
  "UTC", "UTC+1", "UTC+2", "UTC+3", "UTC+3:30", "UTC+4", "UTC+4:30", "UTC+5",
  "UTC+5:30", "UTC+5:45", "UTC+6", "UTC+6:30", "UTC+7", "UTC+8", "UTC+8:45",
  "UTC+9", "UTC+9:30", "UTC+10", "UTC+10:30", "UTC+11", "UTC+12", "UTC+12:45",
  "UTC+13", "UTC+14", "UTC-1", "UTC-2", "UTC-3", "UTC-3:30", "UTC-4",
  "UTC-5", "UTC-6", "UTC-7", "UTC-8", "UTC-9", "UTC-9:30", "UTC-10", "UTC-11", "UTC-12",
];

const huiHttpsList = [
  { key: "Yes", value: 1 },
  { key: "No", value: 0 },
];

const cronResetTraffic = [
  { key: "Monthly", value: "@monthly" },
  { key: "Weekly", value: "@weekly" },
];

const dataFormRules = {
  huiWebPort: [
    {
      required: true,
      message: "Required",
      trigger: ["change", "blur"],
    },
    {
      pattern: /^\d+$/,
      message: "field must be a integer",
      trigger: ["change", "blur"],
    },
  ],
  huiWebContext: [
    {
      required: true,
      message: "Required",
      trigger: ["change", "blur"],
    },
    {
      pattern: /^\/([a-z0-9]+(\/[a-z0-9]+)*)?$/,
      message: "field must start with / and contain only lowercase letters (a-z) and numbers (0-9)",
      trigger: ["change", "blur"],
    },
  ],
  hysteria2TrafficTime: [
    {
      required: true,
      message: "Required",
      trigger: ["change", "blur"],
    },
    {
      pattern: /^\d+(\.\d)?$/,
      message: "field must be a number with up to one decimal place",
      trigger: ["change", "blur"],
    },
  ],
};

const state = reactive({
  dataForm: {
    huiWebPort: "8081",
    huiWebContext: "/",
    hysteria2TrafficTime: "1",
    huiCrtPath: "",
    huiKeyPath: "",
    resetTrafficCron: "",
    timeZone: "",
  },
  huiHttps: 0,
  fileList: [] as UploadUserFile[],
  crtFileList: [] as UploadUserFile[],
  keyFileList: [] as UploadUserFile[],
});

const { dataForm, huiHttps, fileList, crtFileList, keyFileList } =
  toRefs(state);

const submitForm = () => {
  dataFormRef.value.validate((valid: boolean) => {
    if (valid) {
      if (state.huiHttps) {
        if (!state.dataForm.huiCrtPath || !state.dataForm.huiKeyPath) {
          ElMessage.error("crt and key required");
          return;
        }
      }

      if (!state.huiHttps) {
        state.dataForm.huiCrtPath = "";
        state.dataForm.huiKeyPath = "";
      }

      let configs: ConfigsUpdateDto[] = [
        {
          key: huiWebPortKey,
          value: state.dataForm.huiWebPort,
        },
        {
          key: huiWebContext,
          value: state.dataForm.huiWebContext,
        },
        {
          key: hysteria2TrafficTimeKey,
          value: state.dataForm.hysteria2TrafficTime,
        },
        {
          key: huiCrtPathKey,
          value: state.dataForm.huiCrtPath,
        },
        {
          key: huiKeyPathKey,
          value: state.dataForm.huiKeyPath,
        },
        {
          key: resetTrafficCronKey,
          value: state.dataForm.resetTrafficCron,
        },
        {
          key: timeZoneKey,
          value: state.dataForm.timeZone,
        },
      ];

      updateConfigsApi({ configUpdateDtos: configs }).then(() => {
        ElMessage.success(t("common.success"));
      });
    }
  });
};

const setConfig = async () => {
  const { data } = await listConfigApi({
    keys: [
      huiCrtPathKey,
      huiWebContext,
      huiKeyPathKey,
      huiWebPortKey,
      hysteria2TrafficTimeKey,
      resetTrafficCronKey,
      timeZoneKey,
    ],
  });

  data.forEach((configVo) => {
    if (configVo.key === huiWebPortKey) {
      state.dataForm.huiWebPort = configVo.value;
    } else if (configVo.key === huiWebContext) {
      state.dataForm.huiWebContext = configVo.value;
    } else if (configVo.key === hysteria2TrafficTimeKey) {
      state.dataForm.hysteria2TrafficTime = configVo.value;
    } else if (configVo.key === huiCrtPathKey) {
      state.dataForm.huiCrtPath = configVo.value;
    } else if (configVo.key === huiKeyPathKey) {
      state.dataForm.huiKeyPath = configVo.value;
    } else if (configVo.key === resetTrafficCronKey) {
      state.dataForm.resetTrafficCron = configVo.value;
    } else if (configVo.key === timeZoneKey) {
      state.dataForm.timeZone = configVo.value;
    }
  });

  if (state.dataForm.huiCrtPath != "" && state.dataForm.huiKeyPath != "") {
    state.huiHttps = 1;
  }
};

const handleImport = async (params: UploadRequestOptions) => {
  if (state.fileList.length > 0) {
    try {
      let formData = new FormData();
      formData.append("file", params.file);
      await importConfigApi(formData);
      ElMessage.success(t("common.success"));
      state.fileList = [];
    } catch (e) {
      /* empty */
    } finally {
      await setConfig();
    }
  }
};
const beforeImport = (file: UploadRawFile) => {
  if (!file.name.endsWith(".json")) {
    ElMessage.error("file format not supported");
    return false;
  }
  if (file.size / 1024 / 1024 > 2) {
    ElMessage.error("the file is too big, less than 2 MB");
    return false;
  }
};

const handleExport = async () => {
  try {
    let response = await exportConfigApi();
    const blob = new Blob([response.data], {
      type: "application/octet-stream",
    });
    let url = window.URL.createObjectURL(blob);
    let a = document.createElement("a");
    document.body.appendChild(a);
    a.href = url;
    let dis = response.headers["content-disposition"];
    a.download = dis.split("attachment; filename=")[1];
    a.click();
    window.URL.revokeObjectURL(url);
    ElMessage.success(t("common.success"));
  } catch (e) {
    /* empty */
  }
};

const setCertPath = async () => {
  try {
    const { data } = await hysteria2AcmePathApi();
    const { crtPath, keyPath } = data;
    state.dataForm.huiCrtPath = crtPath;
    state.dataForm.huiKeyPath = keyPath;
  } catch (e) {
    /* empty */
  }
};

const uploadCertFile = async (params: UploadRequestOptions) => {
  try {
    if (
      !params.file.name.endsWith(".crt") &&
      !params.file.name.endsWith(".key")
    ) {
      ElMessage.error("file format not supported");
    }
    if (params.file.size > 1024 * 1024) {
      ElMessage.error("the file is too big");
    }
    let formData = new FormData();
    formData.append("file", params.file);
    const { data } = await uploadCertFileApi(formData);
    if (params.file.name.endsWith(".crt")) {
      state.dataForm.huiCrtPath = data;
    } else if (params.file.name.endsWith(".key")) {
      state.dataForm.huiKeyPath = data;
    }
  } catch (e) {
    /* empty */
  }
};

const handleRestartServer = async () => {
  try {
    ElMessageBox.confirm("Are you sure to restart panel?", "Warning", {
      confirmButtonText: t("common.confirm"),
      cancelButtonText: t("common.cancel"),
      type: "warning",
    }).then(() => {
      restartServerApi();
      ElMessage.success(t("config.restartTip"));
    });
  } catch (e) {
    /* empty */
  }
};

onMounted(() => {
  setConfig();
  if (route.query.focus === "huiHttps") {
    nextTick(() => {
      const input = huiHttpsRef.value.$el.querySelector(".el-input__inner");
      if (input) {
        input.focus();
      }
    });
  }
});
</script>

<style lang="scss" scoped>
.page-container {
  padding: 24px;
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  margin-bottom: 28px;

  .header-left {
    .page-title {
      margin: 0 0 6px;
      font-size: 22px;
      font-weight: 700;
      color: var(--el-text-color-primary);
      letter-spacing: -0.3px;
    }
    .page-subtitle {
      margin: 0;
      font-size: 13px;
      color: var(--el-text-color-secondary);
      line-height: 1.4;
    }
  }

  .header-actions {
    display: flex;
    gap: 8px;
    flex-shrink: 0;
  }
}

.settings-grid {
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.settings-card {
  background: var(--el-bg-color);
  border: 1px solid var(--el-border-color-light);
  border-radius: 14px;
  overflow: hidden;
  transition: box-shadow 0.2s ease;

  &:hover {
    box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
  }
}

.card-header {
  display: flex;
  align-items: center;
  gap: 14px;
  padding: 18px 24px;
  border-bottom: 1px solid var(--el-border-color-lighter);
  background: var(--el-fill-color-lighter);
}

.card-icon {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  color: var(--el-color-primary);
  background: color-mix(in srgb, var(--el-color-primary) 12%, transparent);
  flex-shrink: 0;
}

.card-title {
  margin: 0 0 2px;
  font-size: 15px;
  font-weight: 600;
  color: var(--el-text-color-primary);
}

.card-desc {
  margin: 0;
  font-size: 12px;
  color: var(--el-text-color-secondary);
  line-height: 1.4;
}

.card-body {
  padding: 20px 24px;
}

.form-row {
  display: grid;
  gap: 0 24px;

  &.two-col {
    grid-template-columns: 1fr 1fr;
  }

  &.three-col {
    grid-template-columns: 1fr 1fr 1fr;
  }

  &.single-col {
    grid-template-columns: 1fr;
  }

  :deep(.el-form-item) {
    margin-bottom: 0;
  }
}

.https-toggle {
  display: flex;
  gap: 12px;
  align-items: center;
}

.input-with-action {
  display: flex;
  gap: 8px;
  align-items: center;

  .el-input {
    flex: 1;
  }
}

.preference-list {
  display: flex;
  flex-direction: column;
}

.preference-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 0;
  border-bottom: 1px solid var(--el-border-color-lighter);

  &:last-child {
    border-bottom: none;
  }
}

.pref-info {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.pref-label {
  font-size: 14px;
  font-weight: 500;
  color: var(--el-text-color-primary);
}

.pref-hint {
  font-size: 12px;
  color: var(--el-text-color-placeholder);
}

.pref-control {
  :deep(.el-input__wrapper) {
    background: transparent;
    border: none;
    padding: 0;
    box-shadow: none !important;
  }
  :deep(.el-input__inner) {
    font-size: 13px;
    color: var(--el-text-color-regular);
  }
}

.theme-group {
  display: flex;
  gap: 8px;
}

.theme-btn {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
  padding: 8px 14px;
  border-radius: 10px;
  border: 1px solid var(--el-border-color-light);
  cursor: pointer;
  background: var(--el-fill-color-light);
  color: var(--el-text-color-secondary);
  font-size: 18px;
  transition: all 0.2s ease;
  min-width: 64px;

  &:hover {
    background: var(--el-fill-color);
    color: var(--el-color-primary);
    border-color: var(--el-color-primary);
  }

  &.active {
    border-color: var(--el-color-primary);
    color: var(--el-color-primary);
    background: color-mix(in srgb, var(--el-color-primary) 12%, transparent);
    box-shadow: 0 0 0 1px var(--el-color-primary);
  }
}

.theme-btn-label {
  font-size: 10px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.color-group {
  display: flex;
  gap: 8px;
}

.color-swatch {
  width: 28px;
  height: 28px;
  border-radius: 8px;
  cursor: pointer;
  border: 2px solid transparent;
  transition: all 0.2s ease;

  &:hover {
    transform: scale(1.15);
  }

  &.active {
    border-color: var(--el-text-color-primary);
    box-shadow: 0 0 0 2px var(--el-bg-color), 0 0 0 4px currentColor;
  }
}

@media (max-width: 900px) {
  .form-row {
    &.three-col {
      grid-template-columns: 1fr 1fr;
    }
  }
}

@media (max-width: 768px) {
  .page-container { padding: 16px; }

  .page-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
  }

  .form-row {
    &.two-col, &.three-col {
      grid-template-columns: 1fr;
    }
  }

  .card-header { padding: 14px 16px; }
  .card-body { padding: 14px 16px; }
  .settings-card { border-radius: 10px; }

  .preference-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 10px;
  }

  .theme-group { flex-wrap: wrap; }
}
</style>
